import 'package:equatable/equatable.dart';

/// Failures are business-logic error models returned by Repositories and Usecases.
///
/// Unlike exceptions, failures do not crash the app; they are propagated
/// through the BLoC layer to display clean, action-driven error states in the UI.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final String? code;

  const ServerFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No active internet connection. Please check settings.']);
}

class AuthFailure extends Failure {
  final String? code;

  const AuthFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
