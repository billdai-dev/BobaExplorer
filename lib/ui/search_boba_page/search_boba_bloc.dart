import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/favorite/favorite_repo.dart';
import 'package:boba_explorer/data/repo/mapper.dart';
import 'package:boba_explorer/data/repo/search_boba/search_boba_repo.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:rxdart/rxdart.dart';

class SearchBobaBloc extends BlocBase {
  final FavoriteRepo _favoriteRepo;

  final SearchBobaRepo _searchBobaRepo;

  final BehaviorSubject<List<TeaShop>> _favoriteShopsController =
      BehaviorSubject();

  Stream<List<TeaShop>> get favoriteShops => _favoriteShopsController.stream;

  final BehaviorSubject<List<String>> _recentSearchController =
      BehaviorSubject();

  Stream<List<String>> get recentSearch => _recentSearchController.stream;

  SearchBobaBloc(this._favoriteRepo, this._searchBobaRepo) {
    _favoriteShopsController.addStream(
        Observable(_favoriteRepo.getFavoriteShops()).flatMap((favoriteShops) {
      return Observable.fromIterable(favoriteShops)
          .map((favoriteShop) => Mapper.favoriteShopToTeaShop(favoriteShop))
          .toList()
          .asObservable();
    }));

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
    _favoriteShopsController?.close();
    _recentSearchController?.close();
  }

  Future<void> addRecentSearch(String shop) {
    return _searchBobaRepo.addRecentSearch(shop);
  }
}
