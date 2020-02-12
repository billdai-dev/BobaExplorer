import 'dart:io';

import 'package:boba_explorer/data/repository/mapper.dart';
import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

abstract class INetwork {
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser);

  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser);

  Future<FirebaseUser> guestLogin();

  Stream<FirebaseUser> getAuthChangedStream();

  Future<FirebaseUser> getCurrentUser();

  Future<void> logout();

  Stream<List<TeaShop>> fetchTeaShops(double lat, double lng, double radius,
      {Set<String> shopNames});

  Stream<List<TeaShop>> fetchFavoriteShops(String uid);

  Future<void> setFavoriteShop(bool isFavorite, String docId, String uid);

  Future<void> importFavoriteShops(String uid, List<String> ids);

  Future<bool> sendReport(Report report);
}

class Network implements INetwork {
  static const String _collectionTeaShop = "tea_shops";
  static const String _collectionReport = "report";
  static const String _fieldPosition = "position";
  static const String _fieldShopName = "shopName";
  static const String _fieldFavoriteUid = "favoriteUid";

  /*static final String _facebookPackageName =
      Platform.isAndroid ? "com.facebook.katana" : "fb://";*/

  final GoogleSignIn _googleSignIn;
  final FacebookLogin _facebookLogin;
  final FirebaseAuth _auth;
  final Firestore _firestore;
  final Geoflutterfire _geoFlutterFire;

  Network(this._googleSignIn, this._facebookLogin, this._auth, this._firestore,
      this._geoFlutterFire);

  @override
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser?.authentication;
    if (googleAuth == null) {
      return null;
    }
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser newUser;
    if (currentUser == null) {
      newUser = await _auth.signInWithCredential(credential);
    } else if (currentUser.isAnonymous == true) {
      newUser = await _auth.linkWithCredential(credential).catchError((e) {
        if (e is PlatformException &&
            e.code == 'ERROR_CREDENTIAL_ALREADY_IN_USE') {
          return _auth.signInWithCredential(credential);
        }
        throw e; //TODO: Maybe throw custom domain exception
      });
    } else {
      bool wasGoogleUser = currentUser.providerData?.any((provider) =>
              provider.providerId == GoogleAuthProvider.providerId) ==
          true;

      newUser = wasGoogleUser
          ? await currentUser.reauthenticateWithCredential(credential)
          : await _auth.linkWithCredential(credential);
    }
    final googleProviderData = newUser?.providerData?.firstWhere(
        (data) => data.providerId == GoogleAuthProvider.providerId,
        orElse: () => null);
    final profile = UserUpdateInfo()
      ..displayName = googleProviderData?.displayName
      ..photoUrl = googleProviderData?.photoUrl;
    return await newUser
        ?.updateProfile(profile)
        ?.then((_) => _auth.currentUser());
  }

  @override
  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser) async {
    final loginResult = await _facebookLogin.logIn(['email']);
    if (loginResult?.status != FacebookLoginStatus.loggedIn) {
      return null;
    }
    final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: loginResult.accessToken.token);

    FirebaseUser newUser;
    if (currentUser == null) {
      newUser = await _auth.signInWithCredential(credential);
    } else if (currentUser.isAnonymous == true) {
      newUser = await _auth.linkWithCredential(credential).catchError((e) {
        if (e is PlatformException &&
            e.code == 'ERROR_CREDENTIAL_ALREADY_IN_USE') {
          return _auth.signInWithCredential(credential);
        }
        throw e; //TODO: Maybe throw custom domain exception
      });
    } else {
      bool wasFbUser = currentUser?.providerData?.any((provider) =>
              provider.providerId == FacebookAuthProvider.providerId) ==
          true;
      newUser = wasFbUser
          ? await currentUser?.reauthenticateWithCredential(credential)
          : await _auth.linkWithCredential(credential);
    }
    final fbProviderData = newUser?.providerData?.firstWhere(
        (data) => data.providerId == FacebookAuthProvider.providerId,
        orElse: () => null);
    final profile = UserUpdateInfo()
      ..displayName = fbProviderData?.displayName
      ..photoUrl = fbProviderData?.photoUrl;
    return await newUser
        ?.updateProfile(profile)
        ?.then((_) => _auth.currentUser());
  }

  @override
  Future<FirebaseUser> guestLogin() {
    return _auth.signInAnonymously();
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.disconnect().catchError((e) {});
    await _facebookLogin.logOut().catchError((e) {});
    return _auth.signOut();
  }

  @override
  Stream<FirebaseUser> getAuthChangedStream() {
    return _auth.onAuthStateChanged;
  }

  @override
  Future<FirebaseUser> getCurrentUser() {
    return _auth.currentUser();
  }

  @override
  Observable<List<TeaShop>> fetchTeaShops(double lat, double lng, double radius,
      {Set<String> shopNames}) {
    if (shopNames == null || shopNames.isEmpty) {
      return _buildQueryStream(lat, lng, radius);
    }
    List<Stream<List<TeaShop>>> queries = shopNames
        .map((shop) => _buildQueryStream(lat, lng, radius, shopName: shop))
        .toList();
    if (queries.length == 1) {
      return queries.first;
    }
    return Observable.zip<List<TeaShop>, List<TeaShop>>(queries,
        (results) => results.reduce((value, next) => value..addAll(next)));
  }

  Stream<List<TeaShop>> _buildQueryStream(double lat, double lng, double radius,
      {String shopName}) {
    Query query = _firestore.collection(_collectionTeaShop);
    if (shopName != null) {
      query = query.where(_fieldShopName, isEqualTo: shopName);
    }
    final geoPoint = GeoFirePoint(lat, lng);
    return _geoFlutterFire
        .collection(collectionRef: query)
        .within(center: geoPoint, radius: radius, field: _fieldPosition)
        .map((snapshots) => Mapper.docsToTeaShops(snapshots));
  }

  @override
  Stream<List<TeaShop>> fetchFavoriteShops(String uid) {
    return _firestore
        .collection(_collectionTeaShop)
        .where(_fieldFavoriteUid, arrayContains: uid)
        .snapshots()
        .map((querySnapshot) => Mapper.docsToTeaShops(querySnapshot.documents));
  }

  @override
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

  @override
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
    return Future.wait(futures);
  }

  @override
  Future<bool> sendReport(Report report) {
    assert(report != null);
    return _firestore
        .collection(_collectionReport)
        .add(report.toJson())
        .then((value) => value != null);
  }
}
