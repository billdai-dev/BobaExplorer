import 'package:boba_explorer/domain/entity/tea_shop.dart';

abstract class ITeaShopRepository {
  Stream<List<TeaShop>> getTeaShops(
      {double lat, double lng, double radius = 0.5, Set<String> shopNames});
}
