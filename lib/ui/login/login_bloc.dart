import 'dart:async';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/login/login_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final LoginRepo _loginRepo;

  Stream<FirebaseUser> _onAuthChanged;

  final BehaviorSubject<FirebaseUser> _currentUser = BehaviorSubject();

  Stream<FirebaseUser> get currentUser => _currentUser.stream;

  LoginBloc(this._loginRepo) {
    _loginRepo.getCurrentUser().then((user) {
      _currentUser.add(user);
      _onAuthChanged = _loginRepo.getAuthChangedStream();
      _currentUser.addStream(_onAuthChanged);
    });
  }

  Future<FirebaseUser> googleLogin() {
    final user = _currentUser.value;
    return _loginRepo.googleLogin(user);
  }

  Future<FirebaseUser> facebookLogin() {
    final user = _currentUser.value;
    return _loginRepo.facebookLogin(user);
  }

  Future<FirebaseUser> guestLogin() {
    final user = _currentUser.value;
    if (user == null) {
      return null;
    }
    return _loginRepo.guestLogin();
  }

  @override
  void dispose() {
    _onAuthChanged.drain().then((_) => _currentUser?.close());
  }
}
