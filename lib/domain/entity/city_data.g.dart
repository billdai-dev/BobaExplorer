// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityData _$CityDataFromJson(Map<String, dynamic> json) {
  return CityData(
    (json['city'] as List)
        ?.map(
            (e) => e == null ? null : City.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CityDataToJson(CityData instance) => <String, dynamic>{
      'city': instance.city,
    };

City _$CityFromJson(Map<String, dynamic> json) {
  return City(
    json['id'] as int,
    json['name'] as String,
    (json['zone'] as List)
        ?.map(
            (e) => e == null ? null : Zone.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'zone': instance.zone,
    };

Zone _$ZoneFromJson(Map<String, dynamic> json) {
  return Zone(
    json['id'] as int,
    json['city_id'] as int,
    json['name'] as String,
    json['zip_code'] as int,
  );
}

Map<String, dynamic> _$ZoneToJson(Zone instance) => <String, dynamic>{
      'id': instance.id,
      'city_id': instance.cityId,
      'name': instance.name,
      'zip_code': instance.zipCode,
    };
