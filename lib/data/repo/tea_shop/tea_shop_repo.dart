import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

abstract class TeaShopRepoContract {
  Observable<List<DocumentSnapshot>> getTeaShops(
      {double lat, double lng, double radius, Set<String> shopNames});
}

class TeaShopRepo extends BaseRepo implements TeaShopRepoContract {
  static const double _101Lat = 25.0339639;
  static const double _101Lng = 121.5622835;

  TeaShopRepo({Network network, LocalStorage localStorage})
      : super(network: network, localStorage: localStorage);

  @override
  Observable<List<DocumentSnapshot>> getTeaShops(
      {double lat, double lng, double radius = 0.5, Set<String> shopNames}) {
    if (lat == null || lng == null) {
      lat = _101Lat;
      lng = _101Lng;
    }
    return network.fetchTeaShops(lat, lng, radius, shopNames: shopNames);
  }
}
