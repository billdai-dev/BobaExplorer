import 'dart:async';

import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/auth/favorite_use_case.dart';
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
  final DeleteFavoriteShopsUseCase _deleteFavoriteShopsUseCase;
  final SyncRemoteFavoriteShopUseCase _syncRemoteFavoriteShopUseCase;

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
      this._favoriteRepo,
      this._deleteFavoriteShopsUseCase,
      this._syncRemoteFavoriteShopUseCase) {
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
      eventSink.add(Event.clearLocalFavorites());
      return;
    }
    _logoutUseCase.execute().then((logoutStream) {
      return logoutStream.first;
    }).then((_) {
      eventSink.add(Event.userLogout());
      _currentUser.add(null);
    });
  }

  void clearLocalFavorites() {
    var timeBeforeDeletion = DateTime.now();
    _deleteFavoriteShopsUseCase
        .execute()
        .then((stream) => stream.first)
        .then((_) {
      var timeDifference = DateTime.now().difference(timeBeforeDeletion);
      return timeDifference.inSeconds < 2
          ? Future.delayed(timeDifference)
          : null;
    }).then((_) => eventSink.add(Event.localFavoritesCleared()));
  }

  void syncFavoriteShops() {
    _syncRemoteFavoriteShopUseCase
        .execute()
        .then((stream) => stream.first)
        .then((_) => eventSink.add(Event.remoteFavoritesSynced()));
  }
}
