import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

abstract class TeaShopRepoContract {
  Observable<List<DocumentSnapshot>> getTeaShops(
      {double lat, double lng, double radius, Set<String> shopNames});
}

class TeaShopRepo extends BaseRepo implements TeaShopRepoContract {
  static const double _101Lat = 25.0339639;
  static const double _101Lng = 121.5622835;
  static const String _path = "tea_shops";
  static const String _fieldPosition = "position";
  static const String _fieldShopName = "shopName";

  TeaShopRepo({Network network, LocalStorage localStorage})
      : super(network: network, localStorage: localStorage);

  @override
  Observable<List<DocumentSnapshot>> getTeaShops(
      {double lat, double lng, double radius, Set<String> shopNames}) {
    if (lat == null || lng == null) {
      lat = _101Lat;
      lng = _101Lng;
    }
    if (radius == null) {
      radius = 0.5;
    }
    if (shopNames == null || shopNames.isEmpty) {
      return _buildQueryStream(lat, lng, radius);
    }
    List<Stream<List<DocumentSnapshot>>> queries = shopNames
        .map((shop) => _buildQueryStream(lat, lng, radius, shopName: shop))
        .toList();
    if (queries.length == 1) {
      return queries.first;
    }
    return Observable.zip<List<DocumentSnapshot>, List<DocumentSnapshot>>(
      queries,
      (results) => results.reduce((value, next) => value..addAll(next)),
    );
  }

  Stream<List<DocumentSnapshot>> _buildQueryStream(
      double lat, double lng, double radius,
      {String shopName}) {
    Query query = network.firestore.collection(_path);
    if (shopName != null) {
      query = query.where(_fieldShopName, isEqualTo: shopName);
    }
    final geoPoint = GeoFirePoint(lat, lng);
    return network.geoFlutterFire
        .collection(collectionRef: query)
        .within(center: geoPoint, radius: radius, field: _fieldPosition);
  }
}
