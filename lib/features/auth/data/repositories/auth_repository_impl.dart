import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// [AuthRepositoryImpl] — concrete implementation using real Firebase Auth, Google Sign-In, and FlutterSecureStorage.
/// Safeguarded against uninitialized Firebase configurations to prevent runtime exceptions.
class AuthRepositoryImpl implements AuthRepository {
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.networkInfo,
    required this.secureStorage,
  });

  static const String _keyAuthMethod = 'auth_method';
  static const String _keyEmail = 'auth_email';
  static const String _keyPassword = 'auth_password';

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password) async {
    if (!_isFirebaseInitialized) {
      return const Left(AuthFailure('Firebase is not initialized. Please verify your google-services.json setup.'));
    }
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await secureStorage.write(key: _keyAuthMethod, value: 'email');
        await secureStorage.write(key: _keyEmail, value: email);
        await secureStorage.write(key: _keyPassword, value: password);

        return Right(UserEntity(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        ));
      } else {
        return const Left(AuthFailure('No user account returned after signing in.'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed', code: e.code));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    if (!_isFirebaseInitialized) {
      return const Left(AuthFailure('Firebase is not initialized. Please verify your google-services.json setup.'));
    }
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        if (name != null && name.isNotEmpty) {
          await user.updateDisplayName(name);
        }
        await user.reload();
        final updatedUser = _firebaseAuth.currentUser ?? user;

        await secureStorage.write(key: _keyAuthMethod, value: 'email');
        await secureStorage.write(key: _keyEmail, value: email);
        await secureStorage.write(key: _keyPassword, value: password);

        return Right(UserEntity(
          uid: updatedUser.uid,
          email: updatedUser.email ?? '',
          displayName: updatedUser.displayName,
          photoUrl: updatedUser.photoURL,
        ));
      } else {
        return const Left(AuthFailure('No user account returned after account creation.'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed', code: e.code));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!_isFirebaseInitialized) {
      return const Left(AuthFailure('Firebase is not initialized. Please verify your google-services.json setup.'));
    }
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      try {
        await _googleSignIn.initialize();
      } catch (_) {}
      
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      
      if (user != null) {
        await secureStorage.write(key: _keyAuthMethod, value: 'google');

        return Right(UserEntity(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        ));
      } else {
        return const Left(AuthFailure('No user account returned after Google Sign-In.'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Google Sign-In failed', code: e.code));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await secureStorage.delete(key: _keyAuthMethod);
      await secureStorage.delete(key: _keyEmail);
      await secureStorage.delete(key: _keyPassword);
    } catch (_) {}
    try {
      if (_isFirebaseInitialized) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    try {
      if (_isFirebaseInitialized) {
        await _firebaseAuth.signOut();
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> autoLogin() async {
    if (!_isFirebaseInitialized) {
      return const Left(AuthFailure('Firebase is not initialized.'));
    }
    
    try {
      final method = await secureStorage.read(key: _keyAuthMethod);
      if (method == null) {
        return const Left(AuthFailure('No saved session credentials.'));
      }

      final isConnected = await networkInfo.isConnected;

      if (method == 'google') {
        if (!isConnected) {
          return const Left(NetworkFailure());
        }
        
        try {
          await _googleSignIn.initialize();
        } catch (_) {}
        
        final future = _googleSignIn.attemptLightweightAuthentication();
        final googleUser = future != null ? await future : null;
        if (googleUser == null) {
          return const Left(AuthFailure('Google silent sign-in returned no user.'));
        }
        
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        
        final result = await _firebaseAuth.signInWithCredential(credential);
        final user = result.user;
        if (user != null) {
          return Right(UserEntity(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
          ));
        } else {
          return const Left(AuthFailure('No user account returned after Google silent sign-in.'));
        }
      } else if (method == 'email') {
        final email = await secureStorage.read(key: _keyEmail);
        final password = await secureStorage.read(key: _keyPassword);
        
        if (email == null || password == null) {
          return const Left(AuthFailure('Stored email or password not found.'));
        }

        if (!isConnected) {
          return const Left(NetworkFailure());
        }

        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          return Right(UserEntity(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
          ));
        } else {
          return const Left(AuthFailure('No user account returned after email auto-login.'));
        }
      }
      
      return const Left(AuthFailure('Unsupported auto-login method.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
