import 'dart:io';

import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:boba_explorer/data/repo/base_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class LoginRepoContract {
  Future<FirebaseUser> googleLogin();

  Future<FirebaseUser> facebookLogin();

  Stream<FirebaseUser> getAuthChangedStream();

  Future<FirebaseUser> getCurrentUser();
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
  Future<FirebaseUser> googleLogin() async {
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
    return _auth.signInWithCredential(credential).then((result) => result.user);
  }

  @override
  Future<FirebaseUser> facebookLogin() async {
    Map<String, String> appData =
        await AppAvailability.checkAvailability(_facebookPackageName)
            .catchError((e) => null);
    if (appData == null || appData.isEmpty) {
      if (Platform.isIOS) {
        _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      }
    }
    return _facebookLogin
        .logInWithReadPermissions(['email']).then((loginResult) {
      if (loginResult.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: loginResult.accessToken.token);
        return _auth
            .signInWithCredential(credential)
            .then((result) => result.user);
      } else {
        return null;
      }
    });
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
