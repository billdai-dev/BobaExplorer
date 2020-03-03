import 'package:boba_explorer/domain/entity/report.dart';

abstract class IReportRepository {
  Future<bool> report(Report report);
}
