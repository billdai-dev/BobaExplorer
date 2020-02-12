// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) {
  return Report(
    json['reporterUid'] as String,
    json['reportType'] as String,
    json['bug'] == null
        ? null
        : Bug.fromJson(json['bug'] as Map<String, dynamic>),
    json['request'] == null
        ? null
        : Request.fromJson(json['request'] as Map<String, dynamic>),
    json['opinion'] == null
        ? null
        : Opinion.fromJson(json['opinion'] as Map<String, dynamic>),
    json['shop'] == null
        ? null
        : Shop.fromJson(json['shop'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'reporterUid': instance.reporterUid,
      'reportType': instance.reportType,
      'bug': instance.bug?.toJson(),
      'request': instance.request?.toJson(),
      'opinion': instance.opinion?.toJson(),
      'shop': instance.shop?.toJson(),
    };

Bug _$BugFromJson(Map<String, dynamic> json) {
  return Bug(
    json['desc'] as String,
    json['severity'] as int,
  );
}

Map<String, dynamic> _$BugToJson(Bug instance) => <String, dynamic>{
      'desc': instance.desc,
      'severity': instance.severity,
    };

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
    json['city'] as String,
    json['district'] as String,
    json['desc'] as String,
  );
}

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'city': instance.city,
      'district': instance.district,
      'desc': instance.desc,
    };

Opinion _$OpinionFromJson(Map<String, dynamic> json) {
  return Opinion(
    json['desc'] as String,
  );
}

Map<String, dynamic> _$OpinionToJson(Opinion instance) => <String, dynamic>{
      'desc': instance.desc,
    };

Shop _$ShopFromJson(Map<String, dynamic> json) {
  return Shop(
    json['shopId'] as String,
    json['reason'] as String,
  );
}

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
      'shopId': instance.shopId,
      'reason': instance.reason,
    };
