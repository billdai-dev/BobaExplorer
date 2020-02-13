import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/repository/login/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginRepoContract {
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser);

  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser);

  Future<FirebaseUser> guestLogin();

  Stream<FirebaseUser> getAuthChangedStream();

  Future<FirebaseUser> getCurrentUser();

  Future<void> logout();
}

class LoginRepository implements ILoginRepository {
  INetwork _network;

  LoginRepository(this._network);

  @override
  Future<FirebaseUser> googleLogin(FirebaseUser currentUser) async {
    return _network.googleLogin(currentUser);
  }

  @override
  Future<FirebaseUser> facebookLogin(FirebaseUser currentUser) async {
    return _network.facebookLogin(currentUser);
  }

  @override
  Future<FirebaseUser> guestLogin() {
    return _network.guestLogin();
  }

  @override
  Future<void> logout() async {
    return _network.logout();
  }

  @override
  Stream<FirebaseUser> getAuthChangedStream() {
    return _network.getAuthChangedStream();
  }

  @override
  Future<FirebaseUser> getCurrentUser() {
    return _network.getCurrentUser();
  }
}
