import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class BobaMapBloc implements BlocBase {
  static const String path = "tea_shops";
  static const String fieldName = "position";

  final BehaviorSubject<List<DocumentSnapshot>> _bobaController =
      BehaviorSubject();

  Stream<List<DocumentSnapshot>> get bobaData => _bobaController.stream;

  final BehaviorSubject<List<String>> _filterShopListController =
      BehaviorSubject(seedValue: []);

  Stream<List<String>> get filterShopList => _filterShopListController.stream;

  final BehaviorSubject<_QueryConfig> _queryController = BehaviorSubject();

  BobaMapBloc() {
    _queryController.switchMap((config) {
      List<String> filteredShops = _filterShopListController.value;
      if (filteredShops.isEmpty) {
        return _buildQueryStream(config);
      }

      var streams = filteredShops
          .map((shop) => _buildQueryStream(config, shopName: shop))
          .toList();
      if (streams.length == 1) {
        return streams.first;
      }

      return Observable.combineLatest(streams, (allSnapshots) {
        List<DocumentSnapshot> snapshots = [];
        for (var snapshotList in allSnapshots) {
          snapshots.addAll(snapshotList);
        }
        return snapshots;
      });
    }).listen((snapshots) => _bobaController.add(snapshots));
  }

  void seekBoba({double lat, double lng, double radius}) {
    _QueryConfig config = _QueryConfig.copy(_queryController.value);
    if (lat != null && lng != null) {
      config.pos = GeoFirePoint(lat, lng);
    }
    config.radius = radius ?? config.radius ?? 1.0;
    _queryController.add(config);
  }

  void filterShop(String shopName) {
    if (shopName == null || shopName.isEmpty) {
      return;
    }
    List<String> filteredShops = List.from(_filterShopListController.value);
    bool isShopRemoved = filteredShops.remove(shopName);
    _filterShopListController.add(filteredShops);
    if (isShopRemoved) {
      if (filteredShops.isEmpty) {
        seekBoba();
        return;
      }
      List<DocumentSnapshot> shopCacheCopy = List.from(_bobaController.value);
      shopCacheCopy
          .removeWhere((snapshot) => snapshot.data["shopName"] == shopName);
      _bobaController.add(shopCacheCopy);
    } else {
      filteredShops.add(shopName);
      _buildQueryStream(_queryController.value, shopName: shopName)
          .listen((docs) {
        List<DocumentSnapshot> shopCacheCopy = List.from(_bobaController.value);
        List<String> filteredShops = List.from(_filterShopListController.value);
        if (filteredShops.isNotEmpty && filteredShops.length == 1) {
          shopCacheCopy.clear();
        }
        shopCacheCopy.addAll(docs);
        _bobaController.add(shopCacheCopy);
      });
    }
  }

  @override
  void dispose() {
    _bobaController?.close();
    _queryController?.close();
    _filterShopListController?.close();
  }

  Stream<List<DocumentSnapshot>> _buildQueryStream(_QueryConfig config,
      {String shopName}) {
    Query query = Firestore.instance.collection(path);
    if (shopName != null) {
      query = query.where("shopName", isEqualTo: shopName);
    }
    return Geoflutterfire()
        .collection(collectionRef: query)
        .within(center: config.pos, radius: config.radius, field: fieldName);
  }
}

class _QueryConfig {
  GeoFirePoint pos;
  double radius;

  _QueryConfig(this.pos, this.radius);

  _QueryConfig.copy(_QueryConfig config) : this(config?.pos, config?.radius);
}
