import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/ui/login/login_event.dart';

abstract class Event {
  Event();

  factory Event.userLogin(User newUser) => UserLoginEvent(newUser);

  factory Event.showSyncDataDialog(User newUser) =>
      ShowSyncDataDialogEvent(newUser);

  factory Event.userLogout() => UserLogoutEvent();

  factory Event.clearLocalFavoriteShop() => ClearLocalFavoriteShopEvent();
}
