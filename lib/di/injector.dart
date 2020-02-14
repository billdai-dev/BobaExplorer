import 'package:boba_explorer/data/local/moor_db.dart';
import 'package:boba_explorer/data/local/preference.dart';
import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/data/repository/auth/auth_repo.dart';
import 'package:boba_explorer/data/repository/report/report_repository.dart';
import 'package:boba_explorer/data/repository/search_boba/search_boba_repo.dart';
import 'package:boba_explorer/data/repository/tea_shop/tea_shop_repo.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/domain/repository/auth/auth_repository.dart';
import 'package:boba_explorer/domain/repository/report/report_repository.dart';
import 'package:boba_explorer/domain/repository/search_boba/search_boba_repository.dart';
import 'package:boba_explorer/domain/repository/tea_shop/tea_shop_repository.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/auth/favorite_use_case.dart';
import 'package:kiwi/kiwi.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.singleton(INetwork, from: Network)
  @Register.singleton(IPreference, from: Preference)
  @Register.singleton(IDatabase, from: BobaDatabase)
  @Register.factory(IFavoriteRepository, from: FavoriteRepository)
  @Register.factory(IAuthRepository, from: AuthRepository)
  @Register.factory(IReportRepository, from: ReportRepository)
  @Register.factory(ISearchBobaRepository, from: SearchBobaRepository)
  @Register.factory(ITeaShopRepository, from: TeaShopRepository)
  @Register.factory(GoogleLoginUseCase)
  @Register.factory(FacebookLoginUseCase)
  @Register.factory(GuestLoginUseCase)
  @Register.factory(GetUserChangedStreamUseCase)
  @Register.factory(GetCurrentUserUseCase)
  @Register.factory(LogoutUseCase)
  @Register.factory(GetFavoriteShopsStreamUseCase)
  @Register.factory(SetFavoriteShopUseCase)
  @Register.factory(DeleteFavoriteShopsUseCase)
  @Register.factory(SyncRemoteFavoriteShopUseCase)
  /*@Register.factory(GetBannerUseCase)
  @Register.factory(AppBloc)
  @Register.factory(MealDetailBloc)
  @Register.factory(OverviewBloc)*/
  void dev();
}

void inject() {
  var injector = _$Injector();
  injector.dev();
}
