import 'dart:async';

import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BaseBloc {
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
    super.dispose();
    _onAuthChangedListener?.cancel();
    _currentUser?.close();
  }

  void googleLogin() async {
    _googleLoginUseCase.execute().then((googleUserStream) {
      return googleUserStream.first;
    }).then((googleUser) {
      var oldUser = _currentUser.value;
      if (oldUser?.isAnonymous == true) {
        eventSink.add(Event.showSyncDataDialog(googleUser));
      }
      eventSink.add(Event.userLogin(googleUser));
      _currentUser.add(googleUser);
    });
  }

  void facebookLogin() async {
    _facebookLoginUseCase.execute().then((facebookUserStream) {
      return facebookUserStream.first;
    }).then((facebookUser) {
      var oldUser = _currentUser.value;
      if (oldUser?.isAnonymous == true) {
        eventSink.add(Event.showSyncDataDialog(facebookUser));
      }
      eventSink.add(Event.userLogin(facebookUser));
      _currentUser.add(facebookUser);
    });
  }

  void guestLogin() async {
    _guestLoginUseCase.execute().then((guestUserStream) {
      return guestUserStream.first;
    }).then((guestUser) {
      eventSink.add(Event.userLogin(guestUser));
      _currentUser.add(guestUser);
    });
  }

  void logout() {
    var currentUser = _currentUser.value;
    if (currentUser.isAnonymous == true) {
      eventSink.add(Event.clearLocalFavoriteShop());
      return;
    }
    _logoutUseCase.execute().then((logoutStream) {
      return logoutStream.first;
    }).then((_) {
      eventSink.add(Event.userLogout());
      _currentUser.add(null);
    });
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
