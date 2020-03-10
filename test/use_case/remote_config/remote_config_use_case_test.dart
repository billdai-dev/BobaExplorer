import 'package:boba_explorer/domain/entity/supported_shop.dart';
import 'package:boba_explorer/domain/repository/remote_config/remote_config_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/domain_exception.dart';
import 'package:boba_explorer/domain/use_case/remote_config/remote_config_use_case.dart';
import 'package:boba_explorer/domain/use_case/service/device/device_info_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteConfigRepository extends Mock
    implements IRemoteConfigRepository {}

class MockGetAppVersionUseCase extends Mock implements GetAppVersionUseCase {}

class MockExceptionHandler extends Mock implements IExceptionHandler {}

void main() {
  group('RemoteConfig', () {
    IRemoteConfigRepository mockRemoteConfigRepository;
    IExceptionHandler mockExceptionHandler;
    GetAppVersionUseCase mockGetAppVersionUseCase;
    setUp(() {
      mockRemoteConfigRepository = MockRemoteConfigRepository();
      mockExceptionHandler = MockExceptionHandler();
      when(mockExceptionHandler.parse(any))
          .thenReturn(DomainException.resourceNotAvailable());
      mockGetAppVersionUseCase = MockGetAppVersionUseCase();
    });
    test('Get supported shop success', () async {
      List<SupportedShop> shops = [];
      when(mockRemoteConfigRepository.getSupportedShop())
          .thenAnswer((_) => Future.value(shops));
      var getSupportedShopUseCase = GetSupportedShopUseCase(
          mockRemoteConfigRepository, mockExceptionHandler);
      var stream = await getSupportedShopUseCase.execute();
      expect(stream, isA<Stream<List<SupportedShop>>>());
      expect(stream, emits(isA<List<SupportedShop>>()));
      verify(mockRemoteConfigRepository.getSupportedShop()).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Get supported shop failure', () async {
      when(mockRemoteConfigRepository.getSupportedShop()).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));
      var getSupportedShopUseCase = GetSupportedShopUseCase(
          mockRemoteConfigRepository, mockExceptionHandler);
      var stream = await getSupportedShopUseCase.execute();
      expect(stream, isA<Stream<List<SupportedShop>>>());
      expect(stream, emitsError(isA<DomainException>()));
      verify(mockRemoteConfigRepository.getSupportedShop()).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Get supported shop failure', () async {
      when(mockGetAppVersionUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value("1.0.0")));
      CheckAppVersionResponse result =
          CheckAppVersionResponse.forceUpdate("1.0.0", "1.0.1");
      when(mockRemoteConfigRepository.checkAppVersion(any))
          .thenAnswer((_) => Future.value(result));

      var checkAppVersionUseCase = CheckAppVersionUseCase(
          mockGetAppVersionUseCase,
          mockRemoteConfigRepository,
          mockExceptionHandler);
      var stream = await checkAppVersionUseCase.execute();
      expect(stream, isA<Stream<CheckAppVersionResponse>>());
      await expectLater(stream, emits(isA<CheckAppVersionResponse>()));
      verify(mockRemoteConfigRepository.checkAppVersion(any)).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Check app version success', () async {
      String currentVersion = "1.0.0";
      when(mockGetAppVersionUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(currentVersion)));
      CheckAppVersionResponse result =
          CheckAppVersionResponse.forceUpdate(currentVersion, "1.0.1");
      when(mockRemoteConfigRepository.checkAppVersion(any))
          .thenAnswer((_) => Future.value(result));

      var checkAppVersionUseCase = CheckAppVersionUseCase(
          mockGetAppVersionUseCase,
          mockRemoteConfigRepository,
          mockExceptionHandler);
      var stream = await checkAppVersionUseCase.execute();
      expect(stream, isA<Stream<CheckAppVersionResponse>>());
      await expectLater(stream, emits(isA<CheckAppVersionResponse>()));
      /*stream.listen(expectAsync1((val) {
        expect(val.shouldUpdate, true);
        expect(val.forceUpdate, true);
      }));*/
      verify(mockRemoteConfigRepository.checkAppVersion(any)).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Check app version failure, current version is unavailable', () async {
      //String currentVersion = "1.0.0";
      when(mockGetAppVersionUseCase.execute()).thenAnswer((_) =>
          Future(() => Stream.error(DomainException.resourceNotAvailable())));
      /*CheckAppVersionResponse result =
          CheckAppVersionResponse.suggestUpdate(currentVersion, "1.0.1");
      when(mockRemoteConfigRepository.checkAppVersion(any))
          .thenAnswer((_) => Future.value(result));*/

      var checkAppVersionUseCase = CheckAppVersionUseCase(
          mockGetAppVersionUseCase,
          mockRemoteConfigRepository,
          mockExceptionHandler);
      var stream = await checkAppVersionUseCase.execute();
      expect(stream, isA<Stream<CheckAppVersionResponse>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockExceptionHandler.parse(any)).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
    });

    test('Check app version failure', () async {
      String currentVersion = "1.0.0";
      when(mockGetAppVersionUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(currentVersion)));
      when(mockRemoteConfigRepository.checkAppVersion(any)).thenAnswer(
          (_) => Future.error(DomainException.resourceNotAvailable()));

      var checkAppVersionUseCase = CheckAppVersionUseCase(
          mockGetAppVersionUseCase,
          mockRemoteConfigRepository,
          mockExceptionHandler);
      var stream = await checkAppVersionUseCase.execute();
      expect(stream, isA<Stream<CheckAppVersionResponse>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockRemoteConfigRepository.checkAppVersion(any)).called(1);
      verifyNoMoreInteractions(mockRemoteConfigRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });
  });
}
