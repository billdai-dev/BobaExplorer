import 'package:boba_explorer/domain/entity/user.dart';
import 'package:boba_explorer/ui/event.dart';

class UserLoginEvent extends Event {
  final User newUser;

  UserLoginEvent(this.newUser);
}

class ShowSyncDataDialogEvent extends Event {
  final User newUser;

  ShowSyncDataDialogEvent(this.newUser);
}

class UserLogoutEvent extends Event {}

class ClearLocalFavoriteShopEvent extends Event {}
