import 'package:boba_explorer/domain/entity/tea_shop.dart';

abstract class IFavoriteRepository {
  Stream<List<TeaShop>> getFavoriteShops({String uid});

  Future<void> setFavoriteShop(TeaShop teaShop, bool isFavorite, {String uid});

  Future<void> deleteFavoriteShops();

  Future<void> syncRemoteFavoriteShops(String uid);
}
