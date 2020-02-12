import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

const String _reportType_bug = "bug";
const String _reportType_request = "request";
const String _reportType_opinion = "opinion";
const String _reportType_shop = "shop";
const String reportShopReason_location = "location";
const String reportShopReason_data = "data";

@JsonSerializable(explicitToJson: true)
class Report extends Object {
  @JsonKey(name: 'reporterUid')
  String reporterUid;

  @JsonKey(name: 'reportType')
  String reportType;

  @JsonKey(name: 'bug')
  Bug bug;

  @JsonKey(name: 'request')
  Request request;

  @JsonKey(name: 'opinion')
  Opinion opinion;

  @JsonKey(name: 'shop')
  Shop shop;

  Report(
    this.reporterUid,
    this.reportType,
    this.bug,
    this.request,
    this.opinion,
    this.shop,
  );

  Report.bug(String desc, int severity, {String uid})
      : reportType = _reportType_bug,
        reporterUid = uid,
        bug = Bug(desc, severity);

  Report.request(String desc, {String uid, String city, String district})
      : reportType = _reportType_request,
        reporterUid = uid,
        request = Request(city, district, desc);

  Report.opinion(String desc, {String uid})
      : reportType = _reportType_opinion,
        reporterUid = uid,
        opinion = Opinion(desc);

  Report.shop(String shopId, String reason, {String uid})
      : reportType = _reportType_shop,
        reporterUid = uid,
        shop = Shop(shopId, reason);

  factory Report.fromJson(Map<String, dynamic> srcJson) =>
      _$ReportFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ReportToJson(this);
}

@JsonSerializable()
class Bug extends Object {
  @JsonKey(name: 'desc')
  String desc;

  @JsonKey(name: 'severity')
  int severity;

  Bug(
    this.desc,
    this.severity,
  );

  factory Bug.fromJson(Map<String, dynamic> srcJson) => _$BugFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BugToJson(this);
}

@JsonSerializable()
class Request extends Object {
  @JsonKey(name: 'city')
  String city;

  @JsonKey(name: 'district')
  String district;

  @JsonKey(name: 'desc')
  String desc;

  Request(
    this.city,
    this.district,
    this.desc,
  );

  factory Request.fromJson(Map<String, dynamic> srcJson) =>
      _$RequestFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}

@JsonSerializable()
class Opinion extends Object {
  @JsonKey(name: 'desc')
  String desc;

  Opinion(
    this.desc,
  );

  factory Opinion.fromJson(Map<String, dynamic> srcJson) =>
      _$OpinionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$OpinionToJson(this);
}

@JsonSerializable()
class Shop extends Object {
  @JsonKey(name: 'shopId')
  String shopId;

  @JsonKey(name: 'reason')
  String reason;

  Shop(
    this.shopId,
    this.reason,
  );

  factory Shop.fromJson(Map<String, dynamic> srcJson) =>
      _$ShopFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ShopToJson(this);
}
