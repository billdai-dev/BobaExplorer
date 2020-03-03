import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/local/moor_db.dart';
import 'package:boba_explorer/data/local/preference.dart';
import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/data/repository/auth/auth_repo.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/data/repository/remote_config/remote_config_repository.dart';
import 'package:boba_explorer/data/repository/report/report_repository.dart';
import 'package:boba_explorer/data/repository/tea_shop/tea_shop_repository.dart';
import 'package:boba_explorer/data/repository/search_boba/search_boba_repository.dart';
import 'package:boba_explorer/data/service/device_manager.dart';
import 'package:boba_explorer/data/service/exception_handler.dart';
import 'package:boba_explorer/domain/repository/auth/auth_repository.dart';
import 'package:boba_explorer/domain/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/domain/repository/remote_config/remote_config_repository.dart';
import 'package:boba_explorer/domain/repository/report/report_repository.dart';
import 'package:boba_explorer/domain/repository/search_boba/search_boba_repository.dart';
import 'package:boba_explorer/domain/repository/tea_shop/tea_shop_repository.dart';
import 'package:boba_explorer/domain/service/device/device_manager.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/auth/auth_use_case.dart';
import 'package:boba_explorer/domain/use_case/favorite/favorite_use_case.dart';
import 'package:boba_explorer/domain/use_case/remote_config/remote_config_use_case.dart';
import 'package:boba_explorer/domain/use_case/report/report_use_case.dart';
import 'package:boba_explorer/domain/use_case/service/device/device_info_use_case.dart';
import 'package:boba_explorer/domain/use_case/tea_shop/tea_shop_use_case.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:boba_explorer/domain/use_case/search/search_use_case.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/report/report_bloc.dart';
import 'package:boba_explorer/ui/search_boba_page/search_boba_bloc.dart';
import 'package:kiwi/kiwi.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.singleton(INetwork, from: Network)
  @Register.singleton(IPreference, from: Preference)
  @Register.singleton(IDatabase, from: BobaDatabase)
  //Repository
  @Register.factory(IExceptionHandler, from: ExceptionHandler)
  @Register.factory(IFavoriteRepository, from: FavoriteRepository)
  @Register.factory(IAuthRepository, from: AuthRepository)
  @Register.factory(IReportRepository, from: ReportRepository)
  @Register.factory(ISearchBobaRepository, from: SearchBobaRepository)
  @Register.factory(ITeaShopRepository, from: TeaShopRepository)
  @Register.factory(IRemoteConfigRepository, from: RemoteConfigRepository)
  @Register.factory(IDeviceManager, from: DeviceManager)
  //Use case
  //Global
  @Register.factory(GetSupportedShopUseCase)
  @Register.factory(GetAppVersionUseCase)
  @Register.factory(CheckAppVersionUseCase)
  @Register.factory(CheckRatingReminderUseCase)
  @Register.factory(AnswerRatingReminderUseCase)
  //Login
  @Register.factory(GoogleLoginUseCase)
  @Register.factory(FacebookLoginUseCase)
  @Register.factory(GuestLoginUseCase)
  @Register.factory(GetUserChangedStreamUseCase)
  @Register.factory(GetCurrentUserUseCase)
  @Register.factory(LogoutUseCase)
  //Favorite
  @Register.factory(GetFavoriteShopsStreamUseCase)
  @Register.factory(SetFavoriteShopUseCase)
  @Register.factory(DeleteFavoriteShopsUseCase)
  @Register.factory(SyncRemoteFavoriteShopUseCase)
  //Report
  @Register.factory(ReportUseCase)
  //TeaShop
  @Register.factory(FindTeaShopUseCase)
  //RecentSearch
  @Register.factory(GetRecentSearchUseCase)
  @Register.factory(AddRecentSearchUseCase)
  //Bloc
  @Register.factory(AppBloc)
  @Register.factory(LoginBloc)
  @Register.factory(ReportBloc)
  @Register.factory(BobaMapBloc)
  @Register.factory(SearchBobaBloc)
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
