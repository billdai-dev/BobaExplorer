import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/use_case/auth/favorite_use_case.dart';

abstract class IFavoriteRepository {
  Stream<List<TeaShop>> getFavoriteShops({String uid});

  Future<void> setFavoriteShop(TeaShop teaShop, bool isFavorite, {String uid});

  Future<void> deleteFavoriteShops();

  Future<void> syncRemoteFavoriteShops(String uid);
}
