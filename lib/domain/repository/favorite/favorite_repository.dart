import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/use_case/auth/favorite_use_case.dart';

abstract class IFavoriteRepository {
  Stream<List<TeaShop>> getFavoriteShops();

  Future<void> setFavoriteShop(SetFavoriteShopParam param);

  Future<void> deleteFavoriteShops();

  Future<void> syncRemoteFavoriteShops(String uid);
}
