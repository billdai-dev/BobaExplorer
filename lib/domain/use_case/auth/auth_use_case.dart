import 'dart:async';

import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/repository/auth/auth_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class GoogleLoginUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  GoogleLoginUseCase(this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _authRepository.googleLogin();
  }
}

class FacebookLoginUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  FacebookLoginUseCase(this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _authRepository.facebookLogin();
  }
}

class GuestLoginUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  GuestLoginUseCase(this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _authRepository.guestLogin();
  }
}

class GetUserChangedStreamUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  GetUserChangedStreamUseCase(
      this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() async {
    return _authRepository.getAuthChangedStream();
  }
}

class GetCurrentUserUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase(
      this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _authRepository.getCurrentUser();
  }
}

class LogoutUseCase extends UseCase<User> {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _authRepository.logout();
  }
}
