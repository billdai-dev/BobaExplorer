import 'package:boba_explorer/app_event.dart';
import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/ui/login/login_event.dart';
import 'package:boba_explorer/ui/report/report_event.dart';

abstract class Event {
  Event();

  //Global
  factory Event.updateApp(bool forceUpdate, String requiredVersion) =>
      UpdateAppEvent(forceUpdate, requiredVersion);

  factory Event.userLogin(User newUser) => UserLoginEvent(newUser);

  factory Event.showSyncDataDialog(User newUser) =>
      ShowSyncDataDialogEvent(newUser);

  factory Event.userLogout() => UserLogoutEvent();

  factory Event.clearLocalFavorites() => ClearLocalFavoritesEvent();

  factory Event.localFavoritesCleared() => LocalFavoritesClearedEvent();

  factory Event.remoteFavoritesSynced() => RemoteFavoritesSyncedEvent();

  //Report
  factory Event.onReported(bool isSuccess) => OnReportedEvent(isSuccess);
}
