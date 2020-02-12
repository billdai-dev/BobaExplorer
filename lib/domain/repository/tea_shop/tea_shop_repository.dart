import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ITeaShopRepository {
  Stream<List<DocumentSnapshot>> getTeaShops(
      {double lat, double lng, double radius, Set<String> shopNames});
}
