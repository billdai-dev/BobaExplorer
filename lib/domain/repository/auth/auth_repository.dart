import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser);

  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser);

  Future<FirebaseUser> guestLogin();

  Stream<FirebaseUser> getAuthChangedStream();

  Future<FirebaseUser> getCurrentUser();

  Future<void> logout();
}
