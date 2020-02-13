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
  }
}
