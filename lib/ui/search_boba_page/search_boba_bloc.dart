import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/mapper.dart';
import 'package:boba_explorer/data/repo/search_boba/search_boba_repo.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop_repo.dart';
import 'package:rxdart/rxdart.dart';

class SearchBobaBloc extends BlocBase {
  final SearchBobaRepo _searchBobaRepo;

  final TeaShopRepo _teaShopRepo;

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
        .map((docs) => Mapper.docToTeaShop(docs))
        .first
        .timeout(Duration(seconds: 20));
  }
}
