import 'dart:io';

import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
    FirebaseUser newUser;
    if (currentUser == null) {
      newUser = await _auth.signInWithCredential(credential);
    } else if (currentUser.isAnonymous == true) {
      newUser = await (_auth.linkWithCredential(credential).catchError((e) {
        if (e is PlatformException &&
            e.code == 'ERROR_CREDENTIAL_ALREADY_IN_USE') {
          return _auth.signInWithCredential(credential);
        }
        throw e;
      }));
    } else {
      bool wasGoogleUser = currentUser?.providerData?.any((provider) =>
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

    FirebaseUser newUser;
    if (currentUser == null) {
      newUser = await _auth.signInWithCredential(credential);
    } else if (currentUser.isAnonymous == true) {
      newUser = await _auth.linkWithCredential(credential);
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
}
