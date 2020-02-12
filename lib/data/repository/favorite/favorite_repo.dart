import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/moor_db.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:boba_explorer/data/repo/mapper.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:rxdart/rxdart.dart';

abstract class FavoriteRepoContract {
  Stream<List<TeaShop>> getFavoriteShops();

  Future<void> setFavoriteShop(bool isFavorite, FavoriteShop shop);

  Future<void> deleteAllFavoriteShops();

  Future<void> syncRemoteFavoriteShops(String uid);
}

class FavoriteRepo extends BaseRepo implements FavoriteRepoContract {
  FavoriteRepo({Network network, LocalStorage localStorage})
      : super(network: network, localStorage: localStorage);

  @override
  Stream<List<TeaShop>> getFavoriteShops({String uid}) {
    if (uid == null) {
      return Observable(localStorage.loadFavoriteShops())
          .flatMap((favoriteShops) {
        return Observable.fromIterable(favoriteShops)
            .map((shop) => Mapper.favoriteShopToTeaShop(shop))
            .toList()
            .asObservable();
      });
    }
    return Observable(network.fetchFavoriteShops(uid))
        .map((docs) => Mapper.docsToTeaShops(docs));
  }

  @override
  Future<void> setFavoriteShop(bool isFavorite, FavoriteShop shop,
      {String uid}) {
    if (uid == null) {
      return localStorage.setFavoriteShops(isFavorite, shop);
    }
    return network.setFavoriteShop(isFavorite, shop.docId, uid);
  }

  @override
  Future<void> deleteAllFavoriteShops() {
    return localStorage.deleteAllFavoriteShops();
  }

  @override
  Future<void> syncRemoteFavoriteShops(String uid) async {
    if (uid == null) {
      return null;
    }
    return localStorage
        .loadFavoriteShops()
        .first
        .then(
            (favoriteShops) => favoriteShops.map((shop) => shop.docId).toList())
        .then((ids) => network.importFavoriteShops(uid, ids));
  }
}
