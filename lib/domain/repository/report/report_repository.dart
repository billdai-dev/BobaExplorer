abstract class IReportRepository {
  Future<bool> reportBug(String desc, int severity, {String uid});

  Future<bool> reportRequest(String desc,
      {String uid, String city, String district});

  Future<bool> reportOpinion(String desc, {String uid});

  Future<bool> reportShop(String shopId, String reason, {String uid});
}
