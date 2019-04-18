import 'dart:async';
import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc implements BlocBase {
  final BehaviorSubject<List<Shop>> _supportedShopsController =
      BehaviorSubject();

  Stream<List<Shop>> get supportedShops => _supportedShopsController.stream;

  RemoteConfig remoteConfig;

  AppBloc() {
    RemoteConfig.instance.then((rc) async {
      remoteConfig = rc;
      final defaults = <String, dynamic>{"supportedShops": "{'shops':[]}"};
      await rc.setDefaults(defaults);
      bool isDebugMode = false;
      assert(() {
        isDebugMode = true;
        return true;
      }());
      await rc.setConfigSettings(RemoteConfigSettings(debugMode: isDebugMode));
      await rc.fetch(expiration: const Duration(minutes: 15));
      await rc.activateFetched();
      String shops = rc.getString("supportedShops");
      RemoteConfigModel config =
          RemoteConfigModel.fromJsonMap(jsonDecode(shops));
      _supportedShopsController.add(config?.shops);
    });
  }

  @override
  void dispose() {
    _supportedShopsController?.close();
  }
}
