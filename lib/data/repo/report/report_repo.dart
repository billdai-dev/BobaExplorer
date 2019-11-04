import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:boba_explorer/data/repo/report/report.dart';

abstract class ReportRepoContract {
  Future<bool> reportBug(String desc, int severity, {String uid});

  Future<bool> reportRequest(String desc,
      {String uid, String city, String district});

  Future<bool> reportOpinion(String desc, {String uid});

  Future<bool> reportShop(String shopId, String reason, {String uid});
}

class ReportRepo extends BaseRepo implements ReportRepoContract {
  @override
  Future<bool> reportBug(String desc, int severity, {String uid}) {
    Report bugReport = Report.bug(desc, severity, uid: uid);
    return network
        .sendReport(bugReport)
        .then((ref) => ref != null)
        .catchError((e) => false);
  }

  @override
  Future<bool> reportRequest(String desc,
      {String uid, String city, String district}) {
    Report request =
        Report.request(desc, uid: uid, city: city, district: district);
    return network
        .sendReport(request)
        .then((ref) => ref != null)
        .catchError((e) => false);
  }

  @override
  Future<bool> reportOpinion(String desc, {String uid}) {
    Report opinion = Report.opinion(desc, uid: uid);
    return network
        .sendReport(opinion)
        .then((ref) => ref != null)
        .catchError((e) => false);
  }

  @override
  Future<bool> reportShop(String shopId, String shopName, {String uid}) {
    Report shopReport = Report.shop(shopId, shopName, uid: uid);
    return network
        .sendReport(shopReport)
        .then((ref) => ref != null)
        .catchError((e) => false);
  }
}
