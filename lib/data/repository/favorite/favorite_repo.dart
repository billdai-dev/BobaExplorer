import 'package:boba_explorer/data/local/moor_db.dart';
import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';

class FavoriteRepo implements IFavoriteRepository {
  INetwork _network;
  IDatabase _database;

  FavoriteRepo(this._network, this._database);

  @override
  Stream<List<TeaShop>> getFavoriteShops({String uid}) {
    if (uid == null) {
      return _database.watchFavoriteShops();
    }
    return _network.fetchFavoriteShops(uid);
  }

  @override
  Future<void> setFavoriteShop(bool isFavorite, TeaShop shop, {String uid}) {
    if (uid == null) {
      if (isFavorite) {
        return _database.addFavoriteShop(shop);
      } else {
        return _database.deleteFavoriteShop(shop.docId);
      }
    }
    return _network.setFavoriteShop(isFavorite, shop.docId, uid);
  }

  @override
  Future<void> deleteAllFavoriteShops() {
    return _database.deleteAllFavoriteShops();
  }

  @override
  Future<void> syncRemoteFavoriteShops(String uid) async {
    if (uid == null) {
      return null;
    }
    return _database
        .watchFavoriteShops()
        .first
        .then(
            (favoriteShops) => favoriteShops.map((shop) => shop.docId).toList())
        .then((ids) => _network.importFavoriteShops(uid, ids));
  }
}
