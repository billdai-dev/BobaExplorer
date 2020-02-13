import 'dart:async';

import 'package:boba_explorer/data/repository/auth/auth_repo.dart';
import 'package:boba_explorer/ui/bloc_base.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final AuthRepository _loginRepo;
  final FavoriteRepository _favoriteRepo;

  StreamSubscription<FirebaseUser> _onAuthChangedListener;

  final BehaviorSubject<FirebaseUser> _currentUser = BehaviorSubject();

  Stream<FirebaseUser> get currentUser => _currentUser.stream;

  LoginBloc(this._loginRepo, this._favoriteRepo) {
    _loginRepo.getCurrentUser().then((user) {
      _currentUser.add(user);
      _onAuthChangedListener = _loginRepo
          .getAuthChangedStream()
          .listen((user) => _currentUser.add(user));
    });
  }

  @override
  void dispose() {
    _onAuthChangedListener?.cancel();
    _currentUser?.close();
  }

  Future<FirebaseUser> googleLogin() async {
    final user = _currentUser.value;
    final newUser = await _loginRepo.googleLogin(user);
    if (newUser != null) {
      _currentUser.add(newUser);
    }
    return newUser;
  }

  Future<FirebaseUser> facebookLogin() async {
    final user = _currentUser.value;
    final newUser = await _loginRepo.facebookLogin(user);
    if (newUser != null) {
      _currentUser.add(newUser);
    }
    return newUser;
  }

  Future<FirebaseUser> guestLogin() async {
    final user = _currentUser.value;
    if (user != null) {
      return user;
    }
    return _loginRepo.guestLogin();
  }

  Future<void> logout() {
    return _loginRepo.logout();
  }

  Future<void> deleteAllFavoriteShops() {
    return _favoriteRepo.deleteAllFavoriteShops();
  }

  Future<void> syncFavoriteShops() async {
    String uid = _currentUser.value?.uid;
    if (uid == null) {
      return null;
    }
    return _favoriteRepo.syncRemoteFavoriteShops(uid);
  }
}
