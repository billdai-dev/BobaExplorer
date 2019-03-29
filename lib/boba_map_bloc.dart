import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class BobaMapBloc {
  static const String path = "tea_shops";
  static const String fieldName = "position";

  final BehaviorSubject<List<DocumentSnapshot>> _bobaCntlr = BehaviorSubject();

  final BehaviorSubject<_QueryConfig> _queryCntlr = BehaviorSubject();

  Stream<List<DocumentSnapshot>> get bobaData => _bobaCntlr.stream;

  BobaMapBloc() {
    _queryCntlr.switchMap((config) {
      return Geoflutterfire()
          .collection(collectionRef: Firestore.instance.collection(path))
          .within(center: config.pos, radius: config.radius, field: fieldName);
    }).listen((snapshots) => _bobaCntlr.add(snapshots));
  }

  void seekBoba(double lat, double lng, {double radius}) {
    radius ??= _queryCntlr.value?.radius ?? 1.0;
    _queryCntlr.add(_QueryConfig(GeoFirePoint(lat, lng), radius));
  }

  void dispose() {
    _bobaCntlr?.close();
    _queryCntlr?.close();
  }
}

class _QueryConfig {
  GeoFirePoint _pos;
  double _radius;

  GeoFirePoint get pos => _pos;

  double get radius => _radius;

  _QueryConfig(this._pos, this._radius);
}
