import 'package:boba_explorer/domain/entity/tea_shop.dart';

abstract class IFavoriteRepository {
  Stream<List<TeaShop>> getFavoriteShops();

  Future<void> setFavoriteShop(bool isFavorite, TeaShop shop, {String uid});

  Future<void> deleteAllFavoriteShops();

  Future<void> syncRemoteFavoriteShops(String uid);
}
