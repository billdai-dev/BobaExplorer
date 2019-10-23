// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_db.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class FavoriteShop extends DataClass implements Insertable<FavoriteShop> {
  final String docId;
  final String shopName;
  final String branchName;
  final String phone;
  final String city;
  final String district;
  final String address;
  final String geoHash;
  final double lat;
  final double lng;
  final DateTime createdTs;
  final DateTime updatedTs;
  FavoriteShop(
      {@required this.docId,
      @required this.shopName,
      @required this.branchName,
      this.phone,
      @required this.city,
      @required this.district,
      @required this.address,
      @required this.geoHash,
      @required this.lat,
      @required this.lng,
      this.createdTs,
      this.updatedTs});
  factory FavoriteShop.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return FavoriteShop(
      docId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}doc_id']),
      shopName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}shop_name']),
      branchName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}branch_name']),
      phone:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}phone']),
      city: stringType.mapFromDatabaseResponse(data['${effectivePrefix}city']),
      district: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}district']),
      address:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}address']),
      geoHash: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}geo_hash']),
      lat: doubleType.mapFromDatabaseResponse(data['${effectivePrefix}lat']),
      lng: doubleType.mapFromDatabaseResponse(data['${effectivePrefix}lng']),
      createdTs: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_ts']),
      updatedTs: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_ts']),
    );
  }
  factory FavoriteShop.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return FavoriteShop(
      docId: serializer.fromJson<String>(json['docId']),
      shopName: serializer.fromJson<String>(json['shopName']),
      branchName: serializer.fromJson<String>(json['branchName']),
      phone: serializer.fromJson<String>(json['phone']),
      city: serializer.fromJson<String>(json['city']),
      district: serializer.fromJson<String>(json['district']),
      address: serializer.fromJson<String>(json['address']),
      geoHash: serializer.fromJson<String>(json['geoHash']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      createdTs: serializer.fromJson<DateTime>(json['createdTs']),
      updatedTs: serializer.fromJson<DateTime>(json['updatedTs']),
    );
  }
  @override
  Map<String, dynamic> toJson(
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return {
      'docId': serializer.toJson<String>(docId),
      'shopName': serializer.toJson<String>(shopName),
      'branchName': serializer.toJson<String>(branchName),
      'phone': serializer.toJson<String>(phone),
      'city': serializer.toJson<String>(city),
      'district': serializer.toJson<String>(district),
      'address': serializer.toJson<String>(address),
      'geoHash': serializer.toJson<String>(geoHash),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'createdTs': serializer.toJson<DateTime>(createdTs),
      'updatedTs': serializer.toJson<DateTime>(updatedTs),
    };
  }

  @override
  FavoriteShopsCompanion createCompanion(bool nullToAbsent) {
    return FavoriteShopsCompanion(
      docId:
          docId == null && nullToAbsent ? const Value.absent() : Value(docId),
      shopName: shopName == null && nullToAbsent
          ? const Value.absent()
          : Value(shopName),
      branchName: branchName == null && nullToAbsent
          ? const Value.absent()
          : Value(branchName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      geoHash: geoHash == null && nullToAbsent
          ? const Value.absent()
          : Value(geoHash),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      createdTs: createdTs == null && nullToAbsent
          ? const Value.absent()
          : Value(createdTs),
      updatedTs: updatedTs == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedTs),
    );
  }

  FavoriteShop copyWith(
          {String docId,
          String shopName,
          String branchName,
          String phone,
          String city,
          String district,
          String address,
          String geoHash,
          double lat,
          double lng,
          DateTime createdTs,
          DateTime updatedTs}) =>
      FavoriteShop(
        docId: docId ?? this.docId,
        shopName: shopName ?? this.shopName,
        branchName: branchName ?? this.branchName,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        district: district ?? this.district,
        address: address ?? this.address,
        geoHash: geoHash ?? this.geoHash,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        createdTs: createdTs ?? this.createdTs,
        updatedTs: updatedTs ?? this.updatedTs,
      );
  @override
  String toString() {
    return (StringBuffer('FavoriteShop(')
          ..write('docId: $docId, ')
          ..write('shopName: $shopName, ')
          ..write('branchName: $branchName, ')
          ..write('phone: $phone, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('address: $address, ')
          ..write('geoHash: $geoHash, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('createdTs: $createdTs, ')
          ..write('updatedTs: $updatedTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      docId.hashCode,
      $mrjc(
          shopName.hashCode,
          $mrjc(
              branchName.hashCode,
              $mrjc(
                  phone.hashCode,
                  $mrjc(
                      city.hashCode,
                      $mrjc(
                          district.hashCode,
                          $mrjc(
                              address.hashCode,
                              $mrjc(
                                  geoHash.hashCode,
                                  $mrjc(
                                      lat.hashCode,
                                      $mrjc(
                                          lng.hashCode,
                                          $mrjc(createdTs.hashCode,
                                              updatedTs.hashCode))))))))))));
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is FavoriteShop &&
          other.docId == this.docId &&
          other.shopName == this.shopName &&
          other.branchName == this.branchName &&
          other.phone == this.phone &&
          other.city == this.city &&
          other.district == this.district &&
          other.address == this.address &&
          other.geoHash == this.geoHash &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.createdTs == this.createdTs &&
          other.updatedTs == this.updatedTs);
}

class FavoriteShopsCompanion extends UpdateCompanion<FavoriteShop> {
  final Value<String> docId;
  final Value<String> shopName;
  final Value<String> branchName;
  final Value<String> phone;
  final Value<String> city;
  final Value<String> district;
  final Value<String> address;
  final Value<String> geoHash;
  final Value<double> lat;
  final Value<double> lng;
  final Value<DateTime> createdTs;
  final Value<DateTime> updatedTs;
  const FavoriteShopsCompanion({
    this.docId = const Value.absent(),
    this.shopName = const Value.absent(),
    this.branchName = const Value.absent(),
    this.phone = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.address = const Value.absent(),
    this.geoHash = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.createdTs = const Value.absent(),
    this.updatedTs = const Value.absent(),
  });
  FavoriteShopsCompanion.insert({
    @required String docId,
    @required String shopName,
    @required String branchName,
    this.phone = const Value.absent(),
    @required String city,
    @required String district,
    @required String address,
    @required String geoHash,
    @required double lat,
    @required double lng,
    this.createdTs = const Value.absent(),
    this.updatedTs = const Value.absent(),
  })  : docId = Value(docId),
        shopName = Value(shopName),
        branchName = Value(branchName),
        city = Value(city),
        district = Value(district),
        address = Value(address),
        geoHash = Value(geoHash),
        lat = Value(lat),
        lng = Value(lng);
  FavoriteShopsCompanion copyWith(
      {Value<String> docId,
      Value<String> shopName,
      Value<String> branchName,
      Value<String> phone,
      Value<String> city,
      Value<String> district,
      Value<String> address,
      Value<String> geoHash,
      Value<double> lat,
      Value<double> lng,
      Value<DateTime> createdTs,
      Value<DateTime> updatedTs}) {
    return FavoriteShopsCompanion(
      docId: docId ?? this.docId,
      shopName: shopName ?? this.shopName,
      branchName: branchName ?? this.branchName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      geoHash: geoHash ?? this.geoHash,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdTs: createdTs ?? this.createdTs,
      updatedTs: updatedTs ?? this.updatedTs,
    );
  }
}

class $FavoriteShopsTable extends FavoriteShops
    with TableInfo<$FavoriteShopsTable, FavoriteShop> {
  final GeneratedDatabase _db;
  final String _alias;
  $FavoriteShopsTable(this._db, [this._alias]);
  final VerificationMeta _docIdMeta = const VerificationMeta('docId');
  GeneratedTextColumn _docId;
  @override
  GeneratedTextColumn get docId => _docId ??= _constructDocId();
  GeneratedTextColumn _constructDocId() {
    return GeneratedTextColumn(
      'doc_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _shopNameMeta = const VerificationMeta('shopName');
  GeneratedTextColumn _shopName;
  @override
  GeneratedTextColumn get shopName => _shopName ??= _constructShopName();
  GeneratedTextColumn _constructShopName() {
    return GeneratedTextColumn(
      'shop_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _branchNameMeta = const VerificationMeta('branchName');
  GeneratedTextColumn _branchName;
  @override
  GeneratedTextColumn get branchName => _branchName ??= _constructBranchName();
  GeneratedTextColumn _constructBranchName() {
    return GeneratedTextColumn(
      'branch_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _phoneMeta = const VerificationMeta('phone');
  GeneratedTextColumn _phone;
  @override
  GeneratedTextColumn get phone => _phone ??= _constructPhone();
  GeneratedTextColumn _constructPhone() {
    return GeneratedTextColumn(
      'phone',
      $tableName,
      true,
    );
  }

  final VerificationMeta _cityMeta = const VerificationMeta('city');
  GeneratedTextColumn _city;
  @override
  GeneratedTextColumn get city => _city ??= _constructCity();
  GeneratedTextColumn _constructCity() {
    return GeneratedTextColumn(
      'city',
      $tableName,
      false,
    );
  }

  final VerificationMeta _districtMeta = const VerificationMeta('district');
  GeneratedTextColumn _district;
  @override
  GeneratedTextColumn get district => _district ??= _constructDistrict();
  GeneratedTextColumn _constructDistrict() {
    return GeneratedTextColumn(
      'district',
      $tableName,
      false,
    );
  }

  final VerificationMeta _addressMeta = const VerificationMeta('address');
  GeneratedTextColumn _address;
  @override
  GeneratedTextColumn get address => _address ??= _constructAddress();
  GeneratedTextColumn _constructAddress() {
    return GeneratedTextColumn(
      'address',
      $tableName,
      false,
    );
  }

  final VerificationMeta _geoHashMeta = const VerificationMeta('geoHash');
  GeneratedTextColumn _geoHash;
  @override
  GeneratedTextColumn get geoHash => _geoHash ??= _constructGeoHash();
  GeneratedTextColumn _constructGeoHash() {
    return GeneratedTextColumn(
      'geo_hash',
      $tableName,
      false,
    );
  }

  final VerificationMeta _latMeta = const VerificationMeta('lat');
  GeneratedRealColumn _lat;
  @override
  GeneratedRealColumn get lat => _lat ??= _constructLat();
  GeneratedRealColumn _constructLat() {
    return GeneratedRealColumn(
      'lat',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lngMeta = const VerificationMeta('lng');
  GeneratedRealColumn _lng;
  @override
  GeneratedRealColumn get lng => _lng ??= _constructLng();
  GeneratedRealColumn _constructLng() {
    return GeneratedRealColumn(
      'lng',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdTsMeta = const VerificationMeta('createdTs');
  GeneratedDateTimeColumn _createdTs;
  @override
  GeneratedDateTimeColumn get createdTs => _createdTs ??= _constructCreatedTs();
  GeneratedDateTimeColumn _constructCreatedTs() {
    return GeneratedDateTimeColumn(
      'created_ts',
      $tableName,
      true,
    );
  }

  final VerificationMeta _updatedTsMeta = const VerificationMeta('updatedTs');
  GeneratedDateTimeColumn _updatedTs;
  @override
  GeneratedDateTimeColumn get updatedTs => _updatedTs ??= _constructUpdatedTs();
  GeneratedDateTimeColumn _constructUpdatedTs() {
    return GeneratedDateTimeColumn(
      'updated_ts',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        docId,
        shopName,
        branchName,
        phone,
        city,
        district,
        address,
        geoHash,
        lat,
        lng,
        createdTs,
        updatedTs
      ];
  @override
  $FavoriteShopsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'favorite_shops';
  @override
  final String actualTableName = 'favorite_shops';
  @override
  VerificationContext validateIntegrity(FavoriteShopsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.docId.present) {
      context.handle(
          _docIdMeta, docId.isAcceptableValue(d.docId.value, _docIdMeta));
    } else if (docId.isRequired && isInserting) {
      context.missing(_docIdMeta);
    }
    if (d.shopName.present) {
      context.handle(_shopNameMeta,
          shopName.isAcceptableValue(d.shopName.value, _shopNameMeta));
    } else if (shopName.isRequired && isInserting) {
      context.missing(_shopNameMeta);
    }
    if (d.branchName.present) {
      context.handle(_branchNameMeta,
          branchName.isAcceptableValue(d.branchName.value, _branchNameMeta));
    } else if (branchName.isRequired && isInserting) {
      context.missing(_branchNameMeta);
    }
    if (d.phone.present) {
      context.handle(
          _phoneMeta, phone.isAcceptableValue(d.phone.value, _phoneMeta));
    } else if (phone.isRequired && isInserting) {
      context.missing(_phoneMeta);
    }
    if (d.city.present) {
      context.handle(
          _cityMeta, city.isAcceptableValue(d.city.value, _cityMeta));
    } else if (city.isRequired && isInserting) {
      context.missing(_cityMeta);
    }
    if (d.district.present) {
      context.handle(_districtMeta,
          district.isAcceptableValue(d.district.value, _districtMeta));
    } else if (district.isRequired && isInserting) {
      context.missing(_districtMeta);
    }
    if (d.address.present) {
      context.handle(_addressMeta,
          address.isAcceptableValue(d.address.value, _addressMeta));
    } else if (address.isRequired && isInserting) {
      context.missing(_addressMeta);
    }
    if (d.geoHash.present) {
      context.handle(_geoHashMeta,
          geoHash.isAcceptableValue(d.geoHash.value, _geoHashMeta));
    } else if (geoHash.isRequired && isInserting) {
      context.missing(_geoHashMeta);
    }
    if (d.lat.present) {
      context.handle(_latMeta, lat.isAcceptableValue(d.lat.value, _latMeta));
    } else if (lat.isRequired && isInserting) {
      context.missing(_latMeta);
    }
    if (d.lng.present) {
      context.handle(_lngMeta, lng.isAcceptableValue(d.lng.value, _lngMeta));
    } else if (lng.isRequired && isInserting) {
      context.missing(_lngMeta);
    }
    if (d.createdTs.present) {
      context.handle(_createdTsMeta,
          createdTs.isAcceptableValue(d.createdTs.value, _createdTsMeta));
    } else if (createdTs.isRequired && isInserting) {
      context.missing(_createdTsMeta);
    }
    if (d.updatedTs.present) {
      context.handle(_updatedTsMeta,
          updatedTs.isAcceptableValue(d.updatedTs.value, _updatedTsMeta));
    } else if (updatedTs.isRequired && isInserting) {
      context.missing(_updatedTsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  FavoriteShop map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FavoriteShop.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(FavoriteShopsCompanion d) {
    final map = <String, Variable>{};
    if (d.docId.present) {
      map['doc_id'] = Variable<String, StringType>(d.docId.value);
    }
    if (d.shopName.present) {
      map['shop_name'] = Variable<String, StringType>(d.shopName.value);
    }
    if (d.branchName.present) {
      map['branch_name'] = Variable<String, StringType>(d.branchName.value);
    }
    if (d.phone.present) {
      map['phone'] = Variable<String, StringType>(d.phone.value);
    }
    if (d.city.present) {
      map['city'] = Variable<String, StringType>(d.city.value);
    }
    if (d.district.present) {
      map['district'] = Variable<String, StringType>(d.district.value);
    }
    if (d.address.present) {
      map['address'] = Variable<String, StringType>(d.address.value);
    }
    if (d.geoHash.present) {
      map['geo_hash'] = Variable<String, StringType>(d.geoHash.value);
    }
    if (d.lat.present) {
      map['lat'] = Variable<double, RealType>(d.lat.value);
    }
    if (d.lng.present) {
      map['lng'] = Variable<double, RealType>(d.lng.value);
    }
    if (d.createdTs.present) {
      map['created_ts'] = Variable<DateTime, DateTimeType>(d.createdTs.value);
    }
    if (d.updatedTs.present) {
      map['updated_ts'] = Variable<DateTime, DateTimeType>(d.updatedTs.value);
    }
    return map;
  }

  @override
  $FavoriteShopsTable createAlias(String alias) {
    return $FavoriteShopsTable(_db, alias);
  }
}

abstract class _$BobaDatabase extends GeneratedDatabase {
  _$BobaDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $FavoriteShopsTable _favoriteShops;
  $FavoriteShopsTable get favoriteShops =>
      _favoriteShops ??= $FavoriteShopsTable(this);
  @override
  List<TableInfo> get allTables => [favoriteShops];
}
