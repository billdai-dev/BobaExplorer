import 'dart:async';

import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/favorite/favorite_use_case.dart';
import 'package:boba_explorer/domain/use_case/tea_shop/tea_shop_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class BobaMapBloc extends BaseBloc {
  final FindTeaShopUseCase _findTeaShopUseCase;
  final SetFavoriteShopUseCase _setFavoriteShopUseCase;
  final GetFavoriteShopsStreamUseCase _getFavoriteShopsStreamUseCase;
  final GetUserChangedStreamUseCase _getUserChangedStreamUseCase;

  final BehaviorSubject<List<TeaShop>> _teaShopsController =
      BehaviorSubject(seedValue: []);

  Stream<List<TeaShop>> get teaShops {
    return Observable.combineLatest2<List<TeaShop>, List<TeaShop>,
            List<TeaShop>>(
        _teaShopsController.stream, _favoriteShopsController.stream,
        (shops, favoriteShops) {
      shops.forEach((shop) {
        shop.isFavorite = favoriteShops
            .any((favoriteShop) => shop.docId == favoriteShop.docId);
      });
      return shops;
    });
  }

  final BehaviorSubject<List<TeaShop>> _favoriteShopsController =
      BehaviorSubject(seedValue: []);

  Stream<List<TeaShop>> get favoriteShops => _favoriteShopsController.stream;

  final BehaviorSubject<_QueryConfig> _queryConfigController =
      BehaviorSubject();

  final BehaviorSubject<Set<String>> _filterListController =
      BehaviorSubject(seedValue: {});

  Stream<Set<String>> get filterList => _filterListController.stream;

  final BehaviorSubject<Tuple2<Set<String>, Set<String>>> _prevCurFilters =
      BehaviorSubject();

  BobaMapBloc(this._findTeaShopUseCase, this._setFavoriteShopUseCase,
      this._getFavoriteShopsStreamUseCase, this._getUserChangedStreamUseCase) {
    _queryConfigController.switchMap((config) {
      eventSink.add(Event.changeLoading(true));
      Set<String> filteredShops = _filterListController.value;
      return _findTeaShopUseCase
          .execute(FindTeaShopParam(config.lat, config.lng,
              radius: config.radius, shopNames: filteredShops))
          .then((teaShopStream) => teaShopStream.map((teaShops) {
                teaShops.sort((shop1, shop2) {
                  return _compareTeaShopByDistance(
                      config.lat, config.lng, shop1, shop2);
                });
                return teaShops;
              }))
          .asStream();
    }).listen((teaShopsStream) {
      eventSink.add(Event.changeLoading(false));
      teaShopsStream.listen(_teaShopsController.add);
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
        return Stream<Stream<List<TeaShop>>>.empty();
        /*return Observable.error(
            ArgumentError.notNull("Old and new filters can't be both null"));*/
      }
      //Do query/queries for those new added filters
      final config = _queryConfigController.value;
      eventSink.add(Event.changeLoading(true));
      return _findTeaShopUseCase
          .execute(FindTeaShopParam(config.lat, config.lng,
              radius: config.radius, shopNames: result))
          .then((teaShopsStream) => teaShopsStream.map((teaShops) {
                return teaShops
                  ..addAll(intersectionData)
                  ..sort((shop1, shop2) {
                    return _compareTeaShopByDistance(
                        config.lat, config.lng, shop1, shop2);
                  });
              }))
          .asStream();
    }).listen((teaShopsStream) {
      eventSink.add(Event.changeLoading(false));
      teaShopsStream.listen(_teaShopsController.add);
    });
    //=============================================================

    _getUserChangedStreamUseCase.execute().then((userChangedStream) {
      userChangedStream.listen((_) {
        return _getFavoriteShopsStreamUseCase.execute().then((favoritesStream) {
          return favoritesStream
              .listen((favorites) => _favoriteShopsController.add(favorites));
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      if (!newFilter.remove(shop)) {
        newFilter.add(shop);
      }
    } else {
      newFilter = shops;
    }
    final oldFiltersTuple = _prevCurFilters.value ?? Tuple2({}, {});
    _prevCurFilters.add(Tuple2(oldFiltersTuple.item2, newFilter));
  }

  void setFavoriteShop(bool isFavorite, TeaShop shop) async {
    _setFavoriteShopUseCase.execute(SetFavoriteShopParam(shop, isFavorite));
  }

  void searchSingleShop(TeaShop shop) {
    if (shop != null) {
      _teaShopsController.add([shop]);
      _filterListController.add({shop.shopName});
    }
  }

  int _compareTeaShopByDistance(
      double lat, double lng, TeaShop shop1, TeaShop shop2) {
    if (lat == null || lng == null) {
      return -1;
    }
    var distanceToShop1 = SphericalUtil.computeDistanceBetween(LatLng(lat, lng),
        LatLng(shop1.position?.latitude, shop1.position?.longitude));
    var distanceToShop2 = SphericalUtil.computeDistanceBetween(LatLng(lat, lng),
        LatLng(shop2.position?.latitude, shop2.position?.longitude));
    return (distanceToShop1 - distanceToShop2).toInt();
  }
}

class _QueryConfig {
  double lat;
  double lng;
  double radius;

  _QueryConfig(this.lat, this.lng, this.radius);

  _QueryConfig.copy(_QueryConfig config)
      : this(config?.lat, config?.lng, config?.radius);
}
