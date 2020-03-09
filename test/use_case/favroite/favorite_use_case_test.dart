import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/domain_exception.dart';
import 'package:boba_explorer/domain/use_case/favorite/favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFavoriteRepository extends Mock implements IFavoriteRepository {}

class MockExceptionHandler extends Mock implements IExceptionHandler {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  group('Favorite', () {
    IFavoriteRepository mockFavoriteRepository;
    IExceptionHandler mockExceptionHandler;

    setUp(() {
      mockFavoriteRepository = MockFavoriteRepository();
      mockExceptionHandler = MockExceptionHandler();
      when(mockExceptionHandler.parse(any))
          .thenReturn(DomainException.unknownException());
    });

    test('Get favorite shop stream success', () async {
      var user = User();
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));

      List<TeaShop> shops = [];
      when(mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")))
          .thenAnswer((_) => Stream.value(shops));

      var getFavoriteShopStreamUseCase = GetFavoriteShopsStreamUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await getFavoriteShopStreamUseCase.execute();
      expect(stream, isA<Stream<List<TeaShop>>>());
      await expectLater(stream, emits(shops));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")))
          .called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Get favorite shop stream failure, no current user', () async {
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute()).thenAnswer((_) =>
          Future(() => Stream.error(DomainException.resourceNotAvailable())));

      List<TeaShop> shops = [];
      when(mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")))
          .thenAnswer((_) => Stream.value(shops));

      var getFavoriteShopStreamUseCase = GetFavoriteShopsStreamUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await getFavoriteShopStreamUseCase.execute();
      expect(stream, isA<Stream<List<TeaShop>>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verifyNever(
          mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")));
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Get favorite shop stream failure', () async {
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      var user = User();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));

      when(mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")))
          .thenAnswer((_) => Stream.error(DomainException.unknownException()));

      var getFavoriteShopStreamUseCase = GetFavoriteShopsStreamUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await getFavoriteShopStreamUseCase.execute();
      expect(stream, isA<Stream<List<TeaShop>>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.getFavoriteShops(uid: anyNamed("uid")))
          .called(1);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Set favorite shop success', () async {
      var user = User();
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));

      when(mockFavoriteRepository.setFavoriteShop(any, any,
              uid: anyNamed("uid")))
          .thenAnswer((_) => Future.value(null));

      var setFavoriteShopUseCase = SetFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      SetFavoriteShopParam param = SetFavoriteShopParam(null, true);
      var stream = await setFavoriteShopUseCase.execute(param);
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emits(null));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.setFavoriteShop(any, any,
              uid: anyNamed("uid")))
          .called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Set favorite shop failure, no current user', () async {
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute()).thenAnswer((_) =>
          Future(() => Stream.error(DomainException.unknownException())));

      when(mockFavoriteRepository.setFavoriteShop(any, any,
              uid: anyNamed("uid")))
          .thenAnswer((_) => Future.value(null));

      var setFavoriteShopUseCase = SetFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      SetFavoriteShopParam param = SetFavoriteShopParam(null, true);
      var stream = await setFavoriteShopUseCase.execute(param);
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verifyNever(mockFavoriteRepository.setFavoriteShop(any, any,
          uid: anyNamed("uid")));
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Set favorite shop failure', () async {
      var user = User();
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));

      when(mockFavoriteRepository.setFavoriteShop(any, any,
              uid: anyNamed("uid")))
          .thenAnswer((_) => Future.error(DomainException.unknownException()));

      var setFavoriteShopUseCase = SetFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      SetFavoriteShopParam param = SetFavoriteShopParam(null, true);
      var stream = await setFavoriteShopUseCase.execute(param);
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.setFavoriteShop(any, any,
              uid: anyNamed("uid")))
          .called(1);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Delete all favorite shop success', () async {
      when(mockFavoriteRepository.deleteFavoriteShops())
          .thenAnswer((_) => Future.value(null));

      var deleteFavoriteShopsUseCase = DeleteFavoriteShopsUseCase(
          mockFavoriteRepository, mockExceptionHandler);

      var stream = await deleteFavoriteShopsUseCase.execute();
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emits(null));
      verify(mockFavoriteRepository.deleteFavoriteShops()).called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Delete all favorite shop failure', () async {
      when(mockFavoriteRepository.deleteFavoriteShops())
          .thenAnswer((_) => Future.error(DomainException.unknownException()));

      var deleteFavoriteShopsUseCase = DeleteFavoriteShopsUseCase(
          mockFavoriteRepository, mockExceptionHandler);

      var stream = await deleteFavoriteShopsUseCase.execute();
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockFavoriteRepository.deleteFavoriteShops()).called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Sync remote favorite shop success', () async {
      var user = User();
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));

      when(mockFavoriteRepository.syncRemoteFavoriteShops(any))
          .thenAnswer((_) => Future.value(null));

      var syncRemoteFavoriteShopUseCase = SyncRemoteFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await syncRemoteFavoriteShopUseCase.execute();
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emits(null));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.syncRemoteFavoriteShops(any)).called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Sync remote favorite shop failure, user does not exist', () async {
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute()).thenAnswer((_) =>
          Future(() => Stream.error(DomainException.resourceNotAvailable())));

      var syncRemoteFavoriteShopUseCase = SyncRemoteFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await syncRemoteFavoriteShopUseCase.execute();
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verifyNever(mockFavoriteRepository.syncRemoteFavoriteShops(any));
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Sync remote favorite shop failure', () async {
      var user = User();
      MockGetCurrentUserUseCase mockGetCurrentUserUseCase =
          MockGetCurrentUserUseCase();
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(user)));
      when(mockFavoriteRepository.syncRemoteFavoriteShops(any))
          .thenAnswer((_) => Future.error(DomainException.unknownException()));

      var syncRemoteFavoriteShopUseCase = SyncRemoteFavoriteShopUseCase(
          mockGetCurrentUserUseCase,
          mockFavoriteRepository,
          mockExceptionHandler);

      var stream = await syncRemoteFavoriteShopUseCase.execute();
      expect(stream, isA<Stream<void>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockGetCurrentUserUseCase.execute()).called(1);
      verify(mockFavoriteRepository.syncRemoteFavoriteShops(any)).called(1);
      verifyNoMoreInteractions(mockFavoriteRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });
  });
}
