// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tea_shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeaShop _$TeaShopFromJson(Map<String, dynamic> json) {
  return TeaShop(
    json['shopName'] as String,
    json['branchName'] as String,
    json['city'] as String,
    json['district'] as String,
    json['address'] as String,
    json['phone'] as String,
    json['pinColor'] as int,
    positionConverter(json['position'] as Map),
  );
}

Map<String, dynamic> _$TeaShopToJson(TeaShop instance) => <String, dynamic>{
      'shopName': instance.shopName,
      'branchName': instance.branchName,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
      'phone': instance.phone,
      'pinColor': instance.pinColor,
      'position': instance.position,
    };

Position _$PositionFromJson(Map<String, dynamic> json) {
  return Position(
    json['geohash'] as String,
    (json['latitude'] as num)?.toDouble(),
    (json['longitude'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'geohash': instance.geohash,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
