import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/moor_db.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';

abstract class FavoriteRepoContract {
  Stream<List<FavoriteShop>> getFavoriteShops();

  Future<void> setFavoriteShop(bool isFavorite, FavoriteShop shop);

  Future<void> deleteAllFavoriteShops();
}

class FavoriteRepo extends BaseRepo implements FavoriteRepoContract {
  FavoriteRepo({Network network, LocalStorage localStorage})
      : super(network: network, localStorage: localStorage);

  @override
  Stream<List<FavoriteShop>> getFavoriteShops() {
    return localStorage.loadFavoriteShops();
  }

  @override
  Future<void> setFavoriteShop(bool isFavorite, FavoriteShop shop) {
    return localStorage.setFavoriteShops(isFavorite, shop);
  }

  @override
  Future<void> deleteAllFavoriteShops() {
    return localStorage.deleteAllFavoriteShops();
  }
}
