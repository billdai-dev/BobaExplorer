import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/favorite/favorite_repo.dart';
import 'package:boba_explorer/data/repo/login/login_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final LoginRepo _loginRepo;
  final FavoriteRepo _favoriteRepo;

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
}
