import 'package:boba_explorer/domain/service/device/device_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:rate_my_app/rate_my_app.dart';

class DeviceManager implements IDeviceManager {
  @override
  Future<String> getAppVersion() {
    return PackageInfo.fromPlatform().then((info) => info.version);
  }

  @override
  Future<bool> shouldRemindRating() {
    RateMyApp rateMyApp = RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 0,
        minLaunches: 5,
        remindDays: 1,
        remindLaunches: 5);
    return rateMyApp.init().then((_) => rateMyApp.shouldOpenDialog);
  }

  @override
  Future<Function> answerRatingReminder(bool rated) {
    RateMyApp rateMyApp = RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 0,
        minLaunches: 5,
        remindDays: 1,
        remindLaunches: 5);
    if (rated == true) {
      rateMyApp.doNotOpenAgain = true;
    } else {
      rateMyApp
        ..baseLaunchDate =
            rateMyApp.baseLaunchDate.add(Duration(days: rateMyApp.remindDays))
        ..launches -= rateMyApp.remindLaunches;
    }
    return rateMyApp.save();
  }
}
