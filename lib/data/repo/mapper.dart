import 'package:boba_explorer/data/moor_db.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapper {
  static List<String> rcShopToStrings(List<Shop> shops) {
    return shops.map((shop) => shop.name).toList();
  }

  static List<TeaShop> docsToTeaShops(List<DocumentSnapshot> docs) {
    return docs
        .map((doc) => TeaShop.fromJson(doc.data)..docId = doc.documentID)
        .toList();
  }

  static FavoriteShop teaShopToFavoriteShop(TeaShop teaShop) {
    if (teaShop == null) {
      return null;
    }
    return FavoriteShop(
        docId: teaShop.docId,
        shopName: teaShop.shopName,
        branchName: teaShop.branchName,
        phone: teaShop.phone,
        city: teaShop.city,
        district: teaShop.district,
        address: teaShop.address,
        geoHash: teaShop.position?.geohash,
        lat: teaShop.position?.latitude,
        lng: teaShop.position?.longitude);
  }

  static TeaShop favoriteShopToTeaShop(FavoriteShop favoriteShop) {
    if (favoriteShop == null) {
      return null;
    }
    Position position =
        Position(favoriteShop.geoHash, favoriteShop.lat, favoriteShop.lng);
    return TeaShop(
        favoriteShop.docId,
        favoriteShop.shopName,
        favoriteShop.branchName,
        favoriteShop.city,
        favoriteShop.district,
        favoriteShop.address,
        favoriteShop.phone,
        null,
        position,
        true);
  }
}
