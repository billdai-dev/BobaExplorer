import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'package:boba_explorer/data/repo/tea_shop/tea_shop.g.dart';

Position positionConverter(Map<dynamic, dynamic> json) {
  GeoPoint point = json['geopoint'] as GeoPoint;
  return Position(json['geohash'] as String, point.latitude, point.longitude);
}

@JsonSerializable()
class TeaShop extends Object {
  @JsonKey(name: 'shopName')
  String shopName;

  @JsonKey(name: 'branchName')
  String branchName;

  @JsonKey(name: 'city')
  String city;

  @JsonKey(name: 'district')
  String district;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'pinColor')
  int pinColor;

  @JsonKey(name: 'position', fromJson: positionConverter)
  Position position;

  TeaShop(
    this.shopName,
    this.branchName,
    this.city,
    this.district,
    this.address,
    this.phone,
    this.pinColor,
    this.position,
  );

  factory TeaShop.fromJson(Map<String, dynamic> srcJson) =>
      _$TeaShopFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TeaShopToJson(this);
}

@JsonSerializable()
class Position extends Object {
  @JsonKey(name: 'geohash')
  String geohash;

  @JsonKey(name: 'latitude')
  double latitude;

  @JsonKey(name: 'longitude')
  double longitude;

  Position(
    this.geohash,
    this.latitude,
    this.longitude,
  );

  factory Position.fromJson(Map<String, dynamic> srcJson) =>
      _$PositionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PositionToJson(this);
}
