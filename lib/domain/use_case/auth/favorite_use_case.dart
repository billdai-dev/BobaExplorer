import 'dart:async';

import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class GetFavoriteShopsStreamUseCase extends UseCase<List<TeaShop>> {
  final IFavoriteRepository _favoriteRepository;

  GetFavoriteShopsStreamUseCase(
      this._favoriteRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(StreamController<List<TeaShop>> outputStream) {
    return outputStream.addStream(_favoriteRepository.getFavoriteShops());
  }
}

class SetFavoriteShopUseCase extends ParamUseCase<SetFavoriteShopParam, void> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IFavoriteRepository _favoriteRepository;

  SetFavoriteShopUseCase(this._getCurrentUserUseCase, this._favoriteRepository,
      IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(
      SetFavoriteShopParam param, StreamController<void> outputStream) {
    return _getCurrentUserUseCase
        .execute()
        .then((userStream) => userStream.first)
        .then((user) =>
            _favoriteRepository.setFavoriteShop(param..uid = user?.uid))
        .then((_) => outputStream.add(null));
  }
}

class DeleteFavoriteShopsUseCase extends UseCase<void> {
  final IFavoriteRepository _favoriteRepository;

  DeleteFavoriteShopsUseCase(
      this._favoriteRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(StreamController<void> outputStream) {
    return _favoriteRepository
        .deleteFavoriteShops()
        .then((_) => outputStream.add(null));
  }
}

class SyncRemoteFavoriteShopUseCase extends UseCase<void> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IFavoriteRepository _favoriteRepository;

  SyncRemoteFavoriteShopUseCase(this._getCurrentUserUseCase,
      this._favoriteRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(StreamController<void> outputStream) {
    return _getCurrentUserUseCase
        .execute()
        .then((userStream) => userStream.first)
        .then((user) => _favoriteRepository.syncRemoteFavoriteShops(user?.uid))
        .then((_) => outputStream.add(null));
  }
}

class SetFavoriteShopParam {
  TeaShop teaShop;
  bool isFavorite;
  String uid;

  SetFavoriteShopParam(this.teaShop, this.isFavorite, this.uid);
}
