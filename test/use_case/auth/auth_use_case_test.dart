import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/repository/auth/auth_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/domain_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockExceptionHandler extends Mock implements IExceptionHandler {}

void main() {
  group('Auth', () {
    IAuthRepository mockAuthRepository;
    IExceptionHandler mockExceptionHandler;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockExceptionHandler = MockExceptionHandler();
      when(mockExceptionHandler.parse(any))
          .thenReturn(DomainException.resourceNotAvailable());
    });
    test('Google login success', () async {
      var user = User();
      when(mockAuthRepository.googleLogin())
          .thenAnswer((_) => Future.value(user));
      var googleLoginUseCase =
          GoogleLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await googleLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsInOrder([emits(user)]));
      verify(mockAuthRepository.googleLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Google login failure', () async {
      when(mockAuthRepository.googleLogin()).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));
      var googleLoginUseCase =
          GoogleLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await googleLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.googleLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });
    test('Facebook login success', () async {
      var user = User();
      when(mockAuthRepository.facebookLogin())
          .thenAnswer((_) => Future.value(user));
      var facebookLoginUseCase =
          FacebookLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await facebookLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsInOrder([emits(user)]));
      verify(mockAuthRepository.facebookLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Facebook login failure', () async {
      when(mockAuthRepository.facebookLogin()).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));
      var facebookLoginUseCase =
          FacebookLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await facebookLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.facebookLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Guest login success', () async {
      var user = User();
      when(mockAuthRepository.guestLogin())
          .thenAnswer((_) => Future.value(user));
      var guestLoginUseCase =
          GuestLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await guestLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsInOrder([emits(user)]));
      verify(mockAuthRepository.guestLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Guest login failure', () async {
      when(mockAuthRepository.guestLogin()).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));
      var guestLoginUseCase =
          GuestLoginUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await guestLoginUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.guestLogin()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Get current user success', () async {
      var user = User();
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) => Future.value(user));
      var getCurrentUserUseCase =
          GetCurrentUserUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await getCurrentUserUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsInOrder([emits(user)]));
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Get current user failure', () async {
      when(mockAuthRepository.getCurrentUser()).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));
      var getCurrentUserUseCase =
          GetCurrentUserUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await getCurrentUserUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Get user changed stream success', () async {
      var user = User();
      when(mockAuthRepository.getAuthChangedStream())
          .thenAnswer((_) => Stream.value(user));
      var getAuthChangedStreamUseCase =
          GetUserChangedStreamUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await getAuthChangedStreamUseCase.execute();
      expect(stream, isA<Stream<User>>());
      expect(stream, emitsInOrder([emits(user)]));
      verify(mockAuthRepository.getAuthChangedStream()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Get user changed stream failure', () async {
      when(mockAuthRepository.getAuthChangedStream()).thenAnswer(
          (_) => Stream.error(DomainException.resourceNotAvailable()));
      var getUserChangedStreamUseCase =
          GetUserChangedStreamUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await getUserChangedStreamUseCase.execute();
      expect(stream, isA<Stream<User>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.getAuthChangedStream()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Logout success', () async {
      when(mockAuthRepository.logout()).thenAnswer((_) => Future.value());
      var logoutUseCase =
          LogoutUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await logoutUseCase.execute();
      expect(stream, isA<Stream<void>>());
      expect(stream, emitsInOrder([emits(null)]));
      verify(mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Logout failure', () async {
      when(mockAuthRepository.logout())
          .thenAnswer((_) => Future.error(Exception()));
      var logoutUseCase =
          LogoutUseCase(mockAuthRepository, mockExceptionHandler);
      var stream = await logoutUseCase.execute();
      expect(stream, isA<Stream<void>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });
  });
}
