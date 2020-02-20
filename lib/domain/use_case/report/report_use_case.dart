import 'dart:async';

import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/repository/report/report_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class ReportUseCase extends ParamUseCase<Report, bool> {
  final IReportRepository _reportRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  ReportUseCase(this._reportRepository, this._getCurrentUserUseCase,
      IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(Report param) {
    return _getCurrentUserUseCase
        .execute()
        .then((getUserStream) => getUserStream.first)
        .then(
            (user) => _reportRepository.report(param..reporterUid = user?.uid));
  }
}
