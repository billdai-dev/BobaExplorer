import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/repository/report/report_repository.dart';

class ReportRepository implements IReportRepository {
  INetwork _network;

  ReportRepository(this._network);

  @override
  Future<bool> reportBug(String desc, int severity, {String uid}) {
    Report bugReport = Report.bug(desc, severity, uid: uid);
    return _network.sendReport(bugReport);
  }

  @override
  Future<bool> reportRequest(String desc,
      {String uid, String city, String district}) {
    Report request =
        Report.request(desc, uid: uid, city: city, district: district);
    return _network.sendReport(request);
  }

  @override
  Future<bool> reportOpinion(String desc, {String uid}) {
    Report opinion = Report.opinion(desc, uid: uid);
    return _network.sendReport(opinion);
  }

  @override
  Future<bool> reportShop(String shopId, String shopName, {String uid}) {
    Report shopReport = Report.shop(shopId, shopName, uid: uid);
    return _network.sendReport(shopReport);
  }
}
