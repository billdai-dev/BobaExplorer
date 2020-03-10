import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/repository/report/report_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/domain_exception.dart';
import 'package:boba_explorer/domain/use_case/report/report_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockReportRepository extends Mock implements IReportRepository {}

class MockExceptionHandler extends Mock implements IExceptionHandler {}

class MockGetCurrentUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  group('Report', () {
    GetCurrentUserUseCase mockGetCurrentUserUseCase;
    IReportRepository mockReportRepository;
    IExceptionHandler mockExceptionHandler;
    setUp(() {
      mockGetCurrentUserUseCase = MockGetCurrentUseCase();
      mockReportRepository = MockReportRepository();
      mockExceptionHandler = MockExceptionHandler();
      when(mockExceptionHandler.parse(any))
          .thenReturn(DomainException.resourceNotAvailable());
    });
    test('Report success', () async {
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(User())));

      bool reportResult = true;
      when(mockReportRepository.report(any))
          .thenAnswer((_) => Future.value(reportResult));
      var reportUseCase = ReportUseCase(mockReportRepository,
          mockGetCurrentUserUseCase, mockExceptionHandler);

      var stream = await reportUseCase.execute(Report.opinion(""));
      expect(stream, isA<Stream<bool>>());
      await expectLater(stream, emits(reportResult));
      verify(mockReportRepository.report(any)).called(1);
      verifyNoMoreInteractions(mockReportRepository);
      verifyZeroInteractions(mockExceptionHandler);
    });

    test('Report failure, current user does not exist', () async {
      when(mockGetCurrentUserUseCase.execute()).thenAnswer((_) =>
          Future(() => Stream.error(DomainException.resourceNotAvailable())));
      var reportUseCase = ReportUseCase(mockReportRepository,
          mockGetCurrentUserUseCase, mockExceptionHandler);
      var stream = await reportUseCase.execute(Report.opinion(""));
      expect(stream, isA<Stream<bool>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verifyNever(mockReportRepository.report(any));
      verify(mockExceptionHandler.parse(any)).called(1);
    });

    test('Report failure', () async {
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) => Future(() => Stream.value(User())));
      when(mockReportRepository.report(any))
          .thenAnswer((_) => Future.error(DomainException.unknownException()));
      var reportUseCase = ReportUseCase(mockReportRepository,
          mockGetCurrentUserUseCase, mockExceptionHandler);
      var stream = await reportUseCase.execute(Report.opinion(""));
      expect(stream, isA<Stream<bool>>());
      await expectLater(stream, emitsError(isA<DomainException>()));
      verify(mockReportRepository.report(any)).called(1);
      verifyNoMoreInteractions(mockReportRepository);
      verify(mockExceptionHandler.parse(any)).called(1);
    });
  });
}
