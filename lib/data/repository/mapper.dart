import 'package:boba_explorer/data/local/moor_db.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static User fireBaseUserToUser(FirebaseUser fireBaseUser) {
    return User()
      ..uid = fireBaseUser.uid
      ..providerId = fireBaseUser.providerId
      ..name = fireBaseUser.displayName
      ..photoUrl = fireBaseUser.photoUrl
      ..phoneNumber = fireBaseUser.phoneNumber
      ..email = fireBaseUser.email
      ..userData = fireBaseUser?.providerData?.map((provider) {
        return UserData()
          ..uid = provider.uid
          ..providerId = provider.providerId
          ..name = provider.displayName
          ..photoUrl = provider.photoUrl
          ..phoneNumber = provider.phoneNumber
          ..email = provider.email;
      });
  }
}
