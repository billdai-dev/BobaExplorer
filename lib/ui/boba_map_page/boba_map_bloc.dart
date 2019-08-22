import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class BobaMapBloc implements BlocBase {
  static const String path = "tea_shops";
  static const String fieldName = "position";

  final BehaviorSubject<List<DocumentSnapshot>> _bobaController =
      BehaviorSubject(seedValue: []);

  Stream<List<DocumentSnapshot>> get bobaData => _bobaController.stream;

  final BehaviorSubject<_QueryConfig> _queryConfigController =
      BehaviorSubject();

  final BehaviorSubject<Set<String>> _filterListController =
      BehaviorSubject(seedValue: {});

  Stream<Set<String>> get filterList => _filterListController.stream;

  final PublishSubject<String> _appendSingleFilterController = PublishSubject();

  final PublishSubject<Set<String>> _appendFilterListController =
      PublishSubject();

  final BehaviorSubject<Tuple2<Set<String>, Set<String>>> _prevCurFilters =
      BehaviorSubject();

  BobaMapBloc() {
    _queryConfigController.switchMap((config) {
      Set<String> filteredShops = _filterListController.value;
      return _genQueryObservable(filteredShops);
    }).listen((docs) {
      _bobaController.add(docs);
    });

    _appendSingleFilterController.flatMap((filteredShop) {
      final curFilterList = _filterListController.value;
      bool isOnlyFilter =
          curFilterList.contains(filteredShop) && curFilterList.length == 1;
      return _genQueryObservable({filteredShop}).map(
          (docs) => Tuple2<bool, List<DocumentSnapshot>>(isOnlyFilter, docs));
    }).listen((result) {
      bool isTheOnlyFilter = result.item1;
      List<DocumentSnapshot> docs = result.item2;
      if (isTheOnlyFilter) {
        _bobaController.add(result.item2);
      } else {
        _bobaController.add(List.of(_bobaController.value)..addAll(docs));
      }
    });

    _appendFilterListController.switchMap((newFilterList) {
      return _genQueryObservable(newFilterList);
    }).listen((docs) {
      _bobaController.add(List.of(_bobaController.value)..addAll(docs));
      //_bobaController.add(docs);
    });

    _prevCurFilters.doOnData((filtersTuple) {
      _filterListController.add(filtersTuple.item2);
    }).flatMap((filtersTuple) {
      Set<String> result;
      Set<String> oldFilters = filtersTuple.item1;
      Set<String> newFilters = filtersTuple.item2;
      final curBobaShop = List.of(_bobaController.value);
      final intersection = newFilters.intersection(oldFilters);
      List<DocumentSnapshot> intersectionData = [];

      if (oldFilters.isEmpty) {
        //Select all
        if (newFilters.isEmpty) {
          result = null;
        } else {
          Set<String> newAdded = newFilters.difference(oldFilters);
          result = newAdded;
        }
      } else {
        if (newFilters.isEmpty) {
          result = {};
        } else {
          Set<String> removedShops = oldFilters.difference(newFilters);
          removedShops.forEach((removedShop) => curBobaShop
              .removeWhere((doc) => doc.data["shopName"] == removedShop));
          _bobaController.add(curBobaShop);

          Set<String> addedShops = newFilters.difference(oldFilters);
          result = addedShops.isEmpty ? null : addedShops;

          intersectionData.addAll(curBobaShop);
          intersectionData.retainWhere(
              (doc) => intersection.contains(doc.data["shopName"]));
        }
      }
      return _genQueryObservable(result)
          .map((docs) => docs..addAll(intersectionData));
    }).listen((docs) {
      _bobaController.add(docs);
    }, onError: (e) {
      print(e);
    });
  }

  void seekBoba({double lat, double lng, double radius}) {
    _QueryConfig config = _QueryConfig.copy(_queryConfigController.value);
    if (lat != null && lng != null) {
      config.pos = GeoFirePoint(lat, lng);
    }
    config.radius = radius ?? config.radius ?? 1.0;
    _queryConfigController.add(config);
  }

  void filter({String shop, Set<String> shops}) {
    if (shop == null && shops == null) {
      return;
    }
    Set<String> newFilter;
    if (shop != null) {
      newFilter = Set.of(_filterListController.value);
      if (newFilter.contains(shop)) {
        newFilter.remove(shop);
      } else {
        newFilter.add(shop);
      }
    } else {
      newFilter = shops;
    }
    final oldFiltersTuple = _prevCurFilters.value ?? Tuple2({}, {});
    /*if (oldFiltersTuple.item2.isEmpty && newFilter.isEmpty) {
      return;
    }*/
    _prevCurFilters.add(Tuple2(oldFiltersTuple.item2, newFilter));
  }

  @override
  void dispose() {
    _bobaController?.close();
    _queryConfigController?.close();
    _filterListController?.close();
    _appendSingleFilterController?.close();
    _appendFilterListController?.close();
  }

  Observable<List<DocumentSnapshot>> _genQueryObservable(Set<String> shops) {
    assert(shops != null);
    if (shops.isEmpty) {
      return _buildGeoQueryStream();
    }
    List<Stream<List<DocumentSnapshot>>> queryStreams =
        shops.map((shop) => _buildGeoQueryStream(shopName: shop)).toList();
    if (queryStreams.length == 1) {
      return queryStreams.first;
    }
    return Observable.zip<List<DocumentSnapshot>, List<DocumentSnapshot>>(
      queryStreams,
      (results) => results.reduce((value, next) => value..addAll(next)),
    );
  }

  Stream<List<DocumentSnapshot>> _buildGeoQueryStream(
      {_QueryConfig config, String shopName}) {
    config ??= _queryConfigController.value;
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
