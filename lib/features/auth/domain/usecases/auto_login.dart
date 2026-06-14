import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AutoLogin {
  final AuthRepository repository;

  AutoLogin(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.autoLogin();
  }
}
