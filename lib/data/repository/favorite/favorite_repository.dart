import 'package:boba_explorer/data/local/moor_db.dart';
import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/domain/use_case/auth/favorite_use_case.dart';

class FavoriteRepository implements IFavoriteRepository {
  INetwork _network;
  IDatabase _database;

  FavoriteRepository(this._network, this._database);

  @override
  Stream<List<TeaShop>> getFavoriteShops({String uid}) {
    if (uid == null) {
      return _database.watchFavoriteShops();
    }
    return _network.fetchFavoriteShops(uid);
  }

  @override
  Future<void> setFavoriteShop(TeaShop teaShop, bool isFavorite, {String uid}) {
    if (uid == null) {
      if (isFavorite) {
        return _database.addFavoriteShop(teaShop);
      } else {
        return _database.deleteFavoriteShop(teaShop?.docId);
      }
    }
    return _network.setFavoriteShop(isFavorite, teaShop?.docId, uid);
  }

  @override
  Future<void> deleteFavoriteShops() {
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
