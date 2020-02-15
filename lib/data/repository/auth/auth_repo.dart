import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/repository/auth/auth_repository.dart';

class AuthRepository implements IAuthRepository {
  INetwork _network;

  AuthRepository(this._network);

  @override
  Future<User> googleLogin() async {
    return _network.googleLogin();
  }

  @override
  Future<User> facebookLogin() async {
    return _network.facebookLogin();
  }

  @override
  Future<User> guestLogin() {
    return _network.guestLogin();
  }

  @override
  Future<void> logout() async {
    return _network.logout();
  }

  @override
  Stream<User> getAuthChangedStream() {
    return _network.getAuthChangedStream();
  }

  @override
  Future<User> getCurrentUser() {
    return _network.getCurrentUser();
  }
}
