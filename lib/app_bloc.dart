import 'dart:async';
import 'dart:convert';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc implements BlocBase {
  final BehaviorSubject<List<Shop>> _supportedShopsController =
      BehaviorSubject();

  Stream<List<Shop>> get supportedShops => _supportedShopsController.stream;

  final BehaviorSubject<CheckVersionEvent> _checkAppVersionController =
      BehaviorSubject();

  Stream<CheckVersionEvent> get appVersion => _checkAppVersionController.stream;

  RemoteConfig _remoteConfig;

  AppBloc() {
    RemoteConfig.instance.then((rc) async {
      _remoteConfig = rc;
      String appVersion =
          await PackageInfo.fromPlatform().then((info) => info.version);

      final defaults = <String, dynamic>{
        "supportedShops": "{'shops':[]}",
        "latestAppVersion": appVersion,
        "minAppVersion": "1.0.0"
      };
      await rc.setDefaults(defaults);
      bool isDebugMode = false;
      assert(() {
        isDebugMode = true;
        return true;
      }());
      await rc.setConfigSettings(RemoteConfigSettings(debugMode: isDebugMode));
      await rc.fetch(expiration: Duration(minutes: isDebugMode ? 0 : 15));
      await rc.activateFetched();

      String shops = rc.getString("supportedShops");
      RemoteConfigModel config =
          RemoteConfigModel.fromJsonMap(jsonDecode(shops));
      _supportedShopsController.add(config?.shops);
      String minVersion = rc.getString("minAppVersion");
      String latestVersion = rc.getString("latestAppVersion");

      CheckVersionEvent event =
          _checkAppVersion(appVersion, minVersion, latestVersion);
      _checkAppVersionController.add(event);
    });
  }

  @override
  void dispose() {
    _supportedShopsController?.close();
    _checkAppVersionController?.close();
  }
}

CheckVersionEvent _checkAppVersion(
    String appVersion, String minVersion, String latestVersion) {
  appVersion ??= "1.0.0";
  if (minVersion == null ||
      minVersion.isEmpty ||
      latestVersion == null ||
      latestVersion.isEmpty) {
    return CheckVersionEvent.noUpdates(appVersion);
  }
  //Exclude $version-test or $version-alpha
  /*if (currentVersion.contains("-")) {
    String[] realCurrentVersion = currentVersion.split("-");
    currentVersion = realCurrentVersion[0];
  }*/
  List<String> splitAppVersion = appVersion.split(".");
  List<String> splitMinVersion = minVersion.split(".");
  List<String> splitLatestVersion = latestVersion.split(".");
  if (splitAppVersion.length < 3 ||
      splitMinVersion.length < 3 ||
      splitMinVersion.length < 3) {
    return CheckVersionEvent.noUpdates(appVersion);
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
    return CheckVersionEvent.forceUpdate(appVersion, minVersion);
  }
  /*if (appVersionMajor < minVersionMajor) {
    return CheckVersionEvent.forceUpdate(
        appVersion, minVersion); //Ex. 1.0.0 : 2.0.0
  } */
  //print("latest:$latestVersion");
  bool suggestUpdate = appVersionMajor < latestVersionMajor ||
      (appVersionMajor == latestVersionMajor &&
          appVersionMinor < latestVersionMinor) ||
      (appVersionMajor == latestVersionMajor &&
          appVersionMinor == latestVersionMinor &&
          appVersionPatch < latestVersionPatch);
  if (suggestUpdate) {
    return CheckVersionEvent.suggestUpdate(appVersion, latestVersion);
  }
  return CheckVersionEvent.noUpdates(appVersion);

  /*if (appVersionMajor < latestVersionMajor) {
    return CheckVersionEvent.suggestUpdate(
        appVersion, latestVersion); //Ex. 1.0.0 : 2.0.0
  }
  if (appVersionMajor > minVersionMajor &&
      appVersionMajor > latestVersionMajor) {
    return CheckVersionEvent.noUpdates(appVersion);
  }

  //Now "major" is the same
  if (appVersionMinor < minVersionMinor) {
    return CheckVersionEvent.forceUpdate(
        appVersion, minVersion); //Ex. 1.0.0 : 1.2.0
  }
  if (appVersionMinor < latestVersionMinor) {
    return CheckVersionEvent.suggestUpdate(
        appVersion, latestVersion); //Ex. 1.0.0 : 1.2.0
  }
  if (appVersionMinor > minVersionMinor &&
      appVersionMinor > latestVersionMinor) {
    return CheckVersionEvent.noUpdates(appVersion);
  }

  //Now "minor" is the same
  if (appVersionPatch < minVersionPatch) {
    return CheckVersionEvent.forceUpdate(
        appVersion, minVersion); //Ex. 1.1.0 : 1.1.3
  }
  if (appVersionPatch < latestVersionPatch) {
    return CheckVersionEvent.suggestUpdate(
        appVersion, latestVersion); //Ex. 1.1.0 : 1.1.3
  }
  return CheckVersionEvent.noUpdates(appVersion);*/
}

class CheckVersionEvent {
  bool _shouldUpdate;
  bool _forceUpdate;
  String _version;
  String _requiredVersion;

  CheckVersionEvent.noUpdates(this._version)
      : _shouldUpdate = false,
        _forceUpdate = false;

  CheckVersionEvent.forceUpdate(this._version, this._requiredVersion)
      : _shouldUpdate = true,
        _forceUpdate = true;

  CheckVersionEvent.suggestUpdate(this._version, this._requiredVersion)
      : _shouldUpdate = true,
        _forceUpdate = false;

  String get version => _version;

  bool get forceUpdate => _forceUpdate;

  bool get shouldUpdate => _shouldUpdate;

  String get requiredVersion => _requiredVersion;
}
