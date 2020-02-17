// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// InjectorGenerator
// **************************************************************************

class _$Injector extends Injector {
  void dev() {
    final Container container = Container();
    container.registerSingleton<INetwork, Network>((c) => Network());
    container.registerSingleton<IPreference, Preference>((c) => Preference());
    container.registerSingleton<IDatabase, BobaDatabase>((c) => BobaDatabase());
    container.registerFactory<IExceptionHandler, ExceptionHandler>(
        (c) => ExceptionHandler());
    container.registerFactory<IFavoriteRepository, FavoriteRepository>(
        (c) => FavoriteRepository(c<INetwork>(), c<IDatabase>()));
    container.registerFactory<IFavoriteRepository, FavoriteRepository>(
        (c) => FavoriteRepository(c<INetwork>(), c<IDatabase>()));
    container.registerFactory<IAuthRepository, AuthRepository>(
        (c) => AuthRepository(c<INetwork>()));
    container.registerFactory<IReportRepository, ReportRepository>(
        (c) => ReportRepository(c<INetwork>()));
    container.registerFactory<ISearchBobaRepository, SearchBobaRepository>(
        (c) => SearchBobaRepository(c<IPreference>()));
    container.registerFactory<ITeaShopRepository, TeaShopRepository>(
        (c) => TeaShopRepository(c<INetwork>()));
    container.registerFactory((c) =>
        GoogleLoginUseCase(c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) =>
        FacebookLoginUseCase(c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory(
        (c) => GuestLoginUseCase(c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) => GetUserChangedStreamUseCase(
        c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) =>
        GetCurrentUserUseCase(c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory(
        (c) => LogoutUseCase(c<IAuthRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) => GetFavoriteShopsStreamUseCase(
        c<IFavoriteRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) => SetFavoriteShopUseCase(
        c<GetCurrentUserUseCase>(),
        c<IFavoriteRepository>(),
        c<IExceptionHandler>()));
    container.registerFactory((c) => DeleteFavoriteShopsUseCase(
        c<IFavoriteRepository>(), c<IExceptionHandler>()));
    container.registerFactory((c) => SyncRemoteFavoriteShopUseCase(
        c<GetCurrentUserUseCase>(),
        c<IFavoriteRepository>(),
        c<IExceptionHandler>()));
    container.registerFactory((c) => ReportUseCase(c<IReportRepository>(),
        c<GetCurrentUserUseCase>(), c<IExceptionHandler>()));
    container.registerFactory((c) => LoginBloc(
        c<GoogleLoginUseCase>(),
        c<FacebookLoginUseCase>(),
        c<GuestLoginUseCase>(),
        c<GetCurrentUserUseCase>(),
        c<LogoutUseCase>(),
        c<FavoriteRepository>(),
        c<DeleteFavoriteShopsUseCase>(),
        c<SyncRemoteFavoriteShopUseCase>()));
    container.registerFactory((c) => ReportBloc(c<ReportUseCase>()));
  }
}
