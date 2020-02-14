import 'package:boba_explorer/domain/entity/user.dart';

abstract class IAuthRepository {
  Future<User> googleLogin();

  Future<User> facebookLogin();

  Future<User> guestLogin();

  Stream<User> getAuthChangedStream();

  Future<User> getCurrentUser();

  Future<void> logout();
}
