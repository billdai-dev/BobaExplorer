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
  Future<void> answerRatingReminder(bool rated) {
    RateMyApp rateMyApp = RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 0,
        minLaunches: 5,
        remindDays: 1,
        remindLaunches: 5);
    return rateMyApp.init().then((_) {
      rateMyApp.launches -= 1; //To deny "launches" + 1 in init()
      if (rated == true) {
        rateMyApp.doNotOpenAgain = true;
      } else {
        var nextLaunchDate =
            DateTime.now().add(Duration(days: rateMyApp.remindDays));
        rateMyApp
          ..baseLaunchDate = nextLaunchDate
          ..launches = 0;
      }
      return rateMyApp.save();
    });
  }
}
