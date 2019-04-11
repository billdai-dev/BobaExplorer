import 'dart:async';
import 'dart:convert';

import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class BobaMapBloc {
  static const String path = "tea_shops";
  static const String fieldName = "position";

  final BehaviorSubject<List<DocumentSnapshot>> _bobaController =
      BehaviorSubject();

  Stream<List<DocumentSnapshot>> get bobaData => _bobaController.stream;

  final BehaviorSubject<_QueryConfig> _queryController = BehaviorSubject();

  final BehaviorSubject<List<Shop>> _supportedShopsController =
      BehaviorSubject();

  Stream<List<Shop>> get supportedShops => _supportedShopsController.stream;

  RemoteConfig remoteConfig;

  BobaMapBloc() {
    _queryController.switchMap((config) {
      return Geoflutterfire()
          .collection(collectionRef: Firestore.instance.collection(path))
          .within(center: config.pos, radius: config.radius, field: fieldName);
    }).listen((snapshots) => _bobaController.add(snapshots));
    RemoteConfig.instance.then((rc) async {
      remoteConfig = rc;
      final defaults = <String, dynamic>{"supportedShops": "{'shops':[]}"};
      await remoteConfig.setDefaults(defaults);
      await remoteConfig.fetch(expiration: const Duration(minutes: 15));
      await remoteConfig.activateFetched();
      String shops = remoteConfig.getString("supportedShops");
      RemoteConfigModel config =
          RemoteConfigModel.fromJsonMap(jsonDecode(shops));
      print(config.shops);
      _supportedShopsController.add(config?.shops);
    });
  }

  void seekBoba(double lat, double lng, {double radius}) {
    radius ??= _queryController.value?.radius ?? 1.0;
    _queryController.add(_QueryConfig(GeoFirePoint(lat, lng), radius));
  }

  void dispose() {
    _bobaController?.close();
    _queryController?.close();
    _supportedShopsController?.close();
  }
}

class _QueryConfig {
  GeoFirePoint _pos;
  double _radius;

  GeoFirePoint get pos => _pos;

  double get radius => _radius;

  _QueryConfig(this._pos, this._radius);
}
