import 'package:json_annotation/json_annotation.dart';

part 'city_data.g.dart';

@JsonSerializable()
class CityData extends Object {
  @JsonKey(name: 'city')
  List<City> city;

  CityData(
    this.city,
  );

  factory CityData.fromJson(Map<String, dynamic> srcJson) =>
      _$CityDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CityDataToJson(this);
}

@JsonSerializable()
class City extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'zone')
  List<Zone> zone;

  City(
    this.id,
    this.name,
    this.zone,
  );

  factory City.fromJson(Map<String, dynamic> srcJson) =>
      _$CityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}

@JsonSerializable()
class Zone extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'city_id')
  int cityId;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'zip_code')
  int zipCode;

  Zone(
    this.id,
    this.cityId,
    this.name,
    this.zipCode,
  );

  factory Zone.fromJson(Map<String, dynamic> srcJson) =>
      _$ZoneFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ZoneToJson(this);
}
