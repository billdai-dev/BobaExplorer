import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/favorite/favorite_repo.dart';
import 'package:boba_explorer/data/repo/mapper.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:rxdart/rxdart.dart';

class SearchBobaBloc extends BlocBase {
  FavoriteRepo _favoriteRepo;

  final StreamController<List<TeaShop>> _favoriteShopsController =
      BehaviorSubject();

  Stream<List<TeaShop>> get favoriteShops => _favoriteShopsController.stream;

  SearchBobaBloc(this._favoriteRepo) {
    _favoriteShopsController.addStream(
        Observable(_favoriteRepo.getFavoriteShops()).flatMap((favoriteShops) {
      return Observable.fromIterable(favoriteShops)
          .map((favoriteShop) => Mapper.favoriteShopToTeaShop(favoriteShop))
          .toList()
          .asObservable();
    }));

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
  }
}
