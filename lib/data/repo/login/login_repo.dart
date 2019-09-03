import 'dart:io';

import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class LoginRepoContract {
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser);

  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser);

  Future<FirebaseUser> guestLogin();

  Stream<FirebaseUser> getAuthChangedStream();

  Future<FirebaseUser> getCurrentUser();

  Future<void> logout();
}

class LoginRepo extends BaseRepo implements LoginRepoContract {
  static final String _facebookPackageName =
      Platform.isAndroid ? "com.facebook.katana" : "fb://";

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginRepo({Network network, LocalStorage localStorage})
      : super(network: network, localStorage: localStorage);

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
    if (currentUser?.isAnonymous == true) {
      return _auth.linkWithCredential(credential);
    }
    bool isGoogleUser = currentUser?.providerData?.any((provider) =>
            provider.providerId == GoogleAuthProvider.providerId) ==
        true;
    if (isGoogleUser) {
      return currentUser.reauthenticateWithCredential(credential);
    }
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser) async {
    Map<String, String> appData =
        await AppAvailability.checkAvailability(_facebookPackageName)
            .catchError((e) => null);
    if (appData == null || appData.isEmpty) {
      if (Platform.isIOS) {
        _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      }
    }
    final loginResult =
        await _facebookLogin.logInWithReadPermissions(['email']);
    if (loginResult?.status != FacebookLoginStatus.loggedIn) {
      return null;
    }
    final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: loginResult.accessToken.token);
    if (currentUser?.isAnonymous == true) {
      return _auth.linkWithCredential(credential);
    }
    bool isFacebookUser = currentUser?.providerData?.any((provider) =>
            provider.providerId == FacebookAuthProvider.providerId) ==
        true;
    if (isFacebookUser) {
      return currentUser.reauthenticateWithCredential(credential);
    }
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<FirebaseUser> guestLogin() {
    return _auth.signInAnonymously();
  }

  @override
  Future<void> logout() {
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
}
