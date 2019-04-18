import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class BobaMapBloc implements BlocBase {
  static const String path = "tea_shops";
  static const String fieldName = "position";

  final BehaviorSubject<List<DocumentSnapshot>> _bobaController =
      BehaviorSubject();

  Stream<List<DocumentSnapshot>> get bobaData => _bobaController.stream;

  final BehaviorSubject<_QueryConfig> _queryController = BehaviorSubject();

  BobaMapBloc() {
    _queryController.switchMap((config) {
      return Geoflutterfire()
          .collection(collectionRef: Firestore.instance.collection(path))
          .within(center: config.pos, radius: config.radius, field: fieldName);
    }).listen((snapshots) => _bobaController.add(snapshots));
  }

  void seekBoba(double lat, double lng, {double radius}) {
    radius ??= _queryController.value?.radius ?? 1.0;
    _queryController.add(_QueryConfig(GeoFirePoint(lat, lng), radius));
  }

  @override
  void dispose() {
    _bobaController?.close();
    _queryController?.close();
  }
}

class _QueryConfig {
  GeoFirePoint _pos;
  double _radius;

  GeoFirePoint get pos => _pos;

  double get radius => _radius;

  _QueryConfig(this._pos, this._radius);
}
