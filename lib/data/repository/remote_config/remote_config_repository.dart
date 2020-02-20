import 'package:boba_explorer/data/remote/network.dart';
import 'package:boba_explorer/domain/entity/supported_shop.dart';
import 'package:boba_explorer/domain/repository/remote_config/remote_config_repository.dart';
import 'package:boba_explorer/domain/use_case/remote_config/remote_config_use_case.dart';

class RemoteConfigRepository implements IRemoteConfigRepository {
  final INetwork _network;

  RemoteConfigRepository(this._network);

  @override
  Future<List<SupportedShop>> getSupportedShop() {
    return _network.getSupportedShop();
  }

  @override
  Future<CheckAppVersionResponse> checkAppVersion(String currentVersion) {
    return _network.getAppVersionInfo().then((appVersionInfo) =>
        _checkAppVersion(currentVersion, appVersionInfo.minVersion,
            appVersionInfo.latestVersion));
  }

  CheckAppVersionResponse _checkAppVersion(
      String appVersion, String minVersion, String latestVersion) {
    appVersion ??= "1.0.0";
    if (minVersion.isNotEmpty != true || latestVersion.isNotEmpty != true) {
      return CheckAppVersionResponse.noUpdates(appVersion);
    }
    List<String> splitAppVersion = appVersion.split(".");
    List<String> splitMinVersion = minVersion.split(".");
    List<String> splitLatestVersion = latestVersion.split(".");
    if (splitAppVersion.length < 3 ||
        splitMinVersion.length < 3 ||
        splitMinVersion.length < 3) {
      return CheckAppVersionResponse.noUpdates(appVersion);
    }
    int appVersionMajor = int.parse(splitAppVersion[0]);
    int appVersionMinor = int.parse(splitAppVersion[1]);
    int appVersionPatch = int.parse(splitAppVersion[2]);

    int minVersionMajor = int.parse(splitMinVersion[0]);
    int minVersionMinor = int.parse(splitMinVersion[1]);
    int minVersionPatch = int.parse(splitMinVersion[2]);

    int latestVersionMajor = int.parse(splitLatestVersion[0]);
    int latestVersionMinor = int.parse(splitLatestVersion[1]);
    int latestVersionPatch = int.parse(splitLatestVersion[2]);

    //Check "Force update" first
    bool forceUpdate = appVersionMajor < minVersionMajor ||
        (appVersionMajor == minVersionMajor &&
            appVersionMinor < minVersionMinor) ||
        (appVersionMajor == minVersionMajor &&
            appVersionMinor == minVersionMinor &&
            appVersionPatch < minVersionPatch);
    if (forceUpdate) {
      return CheckAppVersionResponse.forceUpdate(appVersion, minVersion);
    }
    bool suggestUpdate = appVersionMajor < latestVersionMajor ||
        (appVersionMajor == latestVersionMajor &&
            appVersionMinor < latestVersionMinor) ||
        (appVersionMajor == latestVersionMajor &&
            appVersionMinor == latestVersionMinor &&
            appVersionPatch < latestVersionPatch);
    return suggestUpdate
        ? CheckAppVersionResponse.suggestUpdate(appVersion, latestVersion)
        : CheckAppVersionResponse.noUpdates(appVersion);
  }
}
