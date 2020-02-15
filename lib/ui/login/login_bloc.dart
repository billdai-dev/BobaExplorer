import 'dart:async';

import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/ui/bloc_base.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final GoogleLoginUseCase _googleLoginUseCase;
  final FacebookLoginUseCase _facebookLoginUseCase;
  final GuestLoginUseCase _guestLoginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  final FavoriteRepository _favoriteRepo;

  StreamSubscription<User> _onAuthChangedListener;

  final BehaviorSubject<User> _currentUser = BehaviorSubject();

  Stream<User> get currentUser => _currentUser.stream;

  LoginBloc(
      this._googleLoginUseCase,
      this._facebookLoginUseCase,
      this._guestLoginUseCase,
      this._getCurrentUserUseCase,
      this._logoutUseCase,
      this._favoriteRepo) {
    _getCurrentUserUseCase.execute().then((currentUserStream) {
      return currentUserStream.listen((user) => _currentUser.add(user));
    });
  }

  /*LoginBloc(this._loginRepo, this._favoriteRepo) {
    _loginRepo.getCurrentUser().then((user) {
      _currentUser.add(user);
      _onAuthChangedListener = _loginRepo
          .getAuthChangedStream()
          .listen((user) => _currentUser.add(user));
    });
  }*/

  @override
  void dispose() {
    _onAuthChangedListener?.cancel();
    _currentUser?.close();
  }

  Future<User> googleLogin() async {
    return _googleLoginUseCase.execute().then((googleUserStream) {
      return googleUserStream.first;
    }).then((googleUser) {
      _currentUser.add(googleUser);
      return googleUser;
    });
  }

  Future<User> facebookLogin() async {
    return _facebookLoginUseCase.execute().then((facebookUserStream) {
      return facebookUserStream.first;
    }).then((facebookUser) {
      _currentUser.add(facebookUser);
      return facebookUser;
    });
  }

  Future<User> guestLogin() async {
    /*final user = _currentUser.value;
    if (user != null) {
      return user;
    }*/
    return _guestLoginUseCase.execute().then((guestUserStream) {
      return guestUserStream.first;
    }).then((guestUser) {
      _currentUser.add(guestUser);
      return guestUser;
    });
  }

  Future<void> logout() {
    return _logoutUseCase.execute().then((logoutStream) => logoutStream.first);
  }

  Future<void> deleteAllFavoriteShops() {
    return _favoriteRepo.deleteFavoriteShops();
  }

  Future<void> syncFavoriteShops() async {
    String uid = _currentUser.value?.uid;
    if (uid == null) {
      return null;
    }
    return _favoriteRepo.syncRemoteFavoriteShops(uid);
  }
}
