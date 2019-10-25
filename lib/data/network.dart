import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class Network {
  static const String _collectionTeaShop = "tea_shops";
  static const String _fieldPosition = "position";
  static const String _fieldShopName = "shopName";
  static const String _fieldFavoriteUid = "favoriteUid";

  static Network _network;

  Firestore _firestore;

  Geoflutterfire _geoFlutterFire;

  Network._({Firestore firestore, Geoflutterfire geoFlutterFire}) {
    _firestore = firestore ?? Firestore.instance;
    _geoFlutterFire = geoFlutterFire ?? Geoflutterfire();
  }

  static Network getInstance(
      {Firestore firestore, Geoflutterfire geoFlutterFire}) {
    _network ??=
        Network._(firestore: firestore, geoFlutterFire: geoFlutterFire);
    return _network;
  }

  Observable<List<DocumentSnapshot>> fetchTeaShops(
      double lat, double lng, double radius,
      {Set<String> shopNames}) {
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
    Query query = _firestore.collection(_collectionTeaShop);
    if (shopName != null) {
      query = query.where(_fieldShopName, isEqualTo: shopName);
    }
    final geoPoint = GeoFirePoint(lat, lng);
    return _geoFlutterFire
        .collection(collectionRef: query)
        .within(center: geoPoint, radius: radius, field: _fieldPosition);
  }

  Stream<List<DocumentSnapshot>> fetchFavoriteShops(String uid) {
    return _firestore
        .collection(_collectionTeaShop)
        .where(_fieldFavoriteUid, arrayContains: uid)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents);
  }

  Future<void> setFavoriteShop(bool isFavorite, String docId, String uid) {
    if (docId == null || uid == null) {
      return null;
    }
    FieldValue value = isFavorite
        ? FieldValue.arrayUnion([uid])
        : FieldValue.arrayRemove([uid]);
    return _firestore
        .collection(_collectionTeaShop)
        .document(docId)
        .updateData({_fieldFavoriteUid: value});
  }

  Future<void> importFavoriteShops(String uid, List<String> ids) async {
    if (uid == null || ids == null || ids.isEmpty) {
      return null;
    }
    var futures = ids.map((docId) {
      return _firestore
          .collection(_collectionTeaShop)
          .document(docId)
          .updateData({
        _fieldFavoriteUid: FieldValue.arrayUnion([uid])
      });
    });
    return Future.wait(futures).catchError((e) => null);
  }
}
