import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/repository/tea_shop/tea_shop_repository.dart';

class TeaShopRepo implements ITeaShopRepository {
  static const double _101Lat = 25.0339639;
  static const double _101Lng = 121.5622835;

  INetwork _network;

  TeaShopRepo(this._network);

  @override
  Stream<List<TeaShop>> getTeaShops(
      {double lat, double lng, double radius = 0.5, Set<String> shopNames}) {
    if (lat == null || lng == null) {
      lat = _101Lat;
      lng = _101Lng;
    }
    return _network.fetchTeaShops(lat, lng, radius, shopNames: shopNames);
  }
}
