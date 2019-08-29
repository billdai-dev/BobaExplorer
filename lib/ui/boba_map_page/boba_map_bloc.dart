import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/favorite/favorite_repo.dart';
import 'package:boba_explorer/data/repo/mapper.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class BobaMapBloc implements BlocBase {
  TeaShopRepo _teaShopRepo;
  FavoriteRepo _favoriteRepo;

  final BehaviorSubject<List<TeaShop>> _teaShopsController =
      BehaviorSubject(seedValue: []);

  Stream<List<TeaShop>> get teaShops {
    return Observable.combineLatest2<List<TeaShop>, List<TeaShop>,
            List<TeaShop>>(
        _teaShopsController.stream, _favoriteShopsController.stream,
        (shops, favoriteShops) {
      for (var shop in shops) {
        for (var favoriteShop in favoriteShops) {
          if (shop.docId == favoriteShop.docId) {
            shop.isFavorite = true;
          }
        }
      }
      return shops;
    });
  }

  final BehaviorSubject<List<TeaShop>> _favoriteShopsController =
      BehaviorSubject(seedValue: []);

  final BehaviorSubject<_QueryConfig> _queryConfigController =
      BehaviorSubject();

  final BehaviorSubject<Set<String>> _filterListController =
      BehaviorSubject(seedValue: {});

  Stream<Set<String>> get filterList => _filterListController.stream;

  final BehaviorSubject<Tuple2<Set<String>, Set<String>>> _prevCurFilters =
      BehaviorSubject();

  BobaMapBloc(this._teaShopRepo, this._favoriteRepo) {
    _queryConfigController
        .switchMap((config) {
          Set<String> filteredShops = _filterListController.value;
          return _teaShopRepo.getTeaShops(config.lat, config.lng, config.radius,
              shopNames: filteredShops);
        })
        .map(_teaShopConverter)
        .listen((shops) {
          _teaShopsController.add(shops);
        });
    //=============================================================
    _prevCurFilters.doOnData((filtersTuple) {
      _filterListController.add(filtersTuple.item2);
    }).flatMap((filtersTuple) {
      Set<String> result;
      Set<String> oldFilters = filtersTuple.item1;
      Set<String> newFilters = filtersTuple.item2;
      final curBobaShop = List.of(_teaShopsController.value);
      final intersection = newFilters.intersection(oldFilters);
      List<TeaShop> intersectionData = [];

      if (oldFilters.isEmpty) {
        //Both filter lists are empty => Search all shops
        if (newFilters.isEmpty) {
          result = null;
        }
        //Find the new added filters
        Set<String> newAdded = newFilters.difference(oldFilters);
        result = newAdded;
      } else {
        //New filter list is empty => Search all shops
        if (newFilters.isEmpty) {
          result = {};
        }
        //Find the removed filters and remove data from the current tea shop list
        else {
          Set<String> removedShops = oldFilters.difference(newFilters);
          removedShops.forEach((removedShop) =>
              curBobaShop.removeWhere((shop) => shop.shopName == removedShop));
          _teaShopsController.add(curBobaShop);

          Set<String> addedShops = newFilters.difference(oldFilters);
          result = addedShops.isEmpty ? null : addedShops;

          intersectionData.addAll(curBobaShop);
          intersectionData
              .retainWhere((shop) => intersection.contains(shop.shopName));
        }
      }
      //Result is null => No need to search more shops
      if (result == null) {
        return Observable.error(
            ArgumentError.notNull("Old and new filters can't be both null"));
      }
      //Do query/queries for those new added filters
      final config = _queryConfigController.value;
      return _teaShopRepo
          .getTeaShops(config?.lat, config?.lng, config?.radius,
              shopNames: result)
          .map(_teaShopConverter)
          .doOnData((shops) => shops..addAll(intersectionData));
    }).listen((shops) => _teaShopsController.add(shops),
        onError: (e) => print(e));
    //=============================================================

    _favoriteShopsController.addStream(
        Observable(_favoriteRepo.getFavoriteShops()).flatMap((favoriteShops) {
      return Observable.fromIterable(favoriteShops)
          .map((favoriteShop) => Mapper.favoriteShopToTeaShop(favoriteShop))
          .toList()
          .asObservable();
    }));
  }

  @override
  void dispose() {
    _teaShopsController?.close();
    _favoriteShopsController?.close();
    _queryConfigController?.close();
    _filterListController?.close();
  }

  void seekBoba({double lat, double lng, double radius}) {
    _QueryConfig config = _QueryConfig.copy(_queryConfigController.value);
    if (lat != null && lng != null) {
      config?.lat = lat;
      config?.lng = lng;
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
    _prevCurFilters.add(Tuple2(oldFiltersTuple.item2, newFilter));
  }

  void setFavoriteShop(bool isFavorite, TeaShop shop) {
    _favoriteRepo.setFavoriteShop(
        isFavorite, Mapper.teaShopToFavoriteShop(shop));
  }

  List<TeaShop> _teaShopConverter(List<DocumentSnapshot> docs) {
    return docs
        .map((doc) => TeaShop.fromJson(doc.data)..docId = doc.documentID)
        .toList();
  }

/*void _getFavoriteShops() {
    _favoriteShopsController.addStream(
        Observable(_favoriteRepo.getFavoriteShops()).flatMap((favoriteShops) {
      return Observable.fromIterable(favoriteShops)
          .map((favoriteShop) => Mapper.favoriteShopToTeaShop(favoriteShop))
          .toList()
          .asObservable();
    }));
  }*/
}

class _QueryConfig {
  double lat;
  double lng;
  double radius;

  _QueryConfig(this.lat, this.lng, this.radius);

  _QueryConfig.copy(_QueryConfig config)
      : this(config?.lat, config?.lng, config?.radius);
}
