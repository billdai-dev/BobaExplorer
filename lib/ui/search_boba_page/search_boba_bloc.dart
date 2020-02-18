import 'dart:async';

import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/data/repository/mapper.dart';
import 'package:boba_explorer/data/repository/search_boba/search_boba_repo.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/data/repository/tea_shop/tea_shop_repository.dart';
import 'package:rxdart/rxdart.dart';

class SearchBobaBloc extends BaseBloc {
  final SearchBobaRepository _searchBobaRepo;

  final TeaShopRepository _teaShopRepo;

  /*final BehaviorSubject<List<TeaShop>> _searchResultController =
      BehaviorSubject();

  Stream<List<TeaShop>> get searchResult => _searchResultController.stream;*/

  final BehaviorSubject<List<String>> _recentSearchController =
      BehaviorSubject();

  Stream<List<String>> get recentSearch => _recentSearchController.stream;

  SearchBobaBloc(this._searchBobaRepo, this._teaShopRepo) {
    _searchBobaRepo
        .getRecentSearch()
        .then((shops) => _recentSearchController.add(shops));

    /*_favoriteRepo.getFavoriteShops().then((shops) {
      return shops.map((json) {
        return TeaShop.fromJson(jsonDecode(json));
      });
    }).then((shops) {
      _favoriteShopController.add(shops);
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    //_searchResultController?.close();
    _recentSearchController?.close();
  }

  Future<void> addRecentSearch(String shop) {
    return _searchBobaRepo.addRecentSearch(shop);
  }

  Future<List<TeaShop>> searchTeaShop(String name,
      {double lat, double lng, double radius}) {
    return _teaShopRepo
        .getTeaShops(lat: lat, lng: lng, radius: radius, shopNames: {name})
        .first
        .timeout(Duration(seconds: 20));
  }
}
