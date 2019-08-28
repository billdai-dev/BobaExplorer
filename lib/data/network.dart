import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Network {
  static Network _network;

  Firestore _firestore;

  Firestore get firestore => _firestore;

  Geoflutterfire _geoFlutterFire;

  Geoflutterfire get geoFlutterFire => _geoFlutterFire;

  Network._({Firestore firestore, Geoflutterfire geoFlutterFire}) {
    _firestore = firestore ?? Firestore.instance;
    _geoFlutterFire = geoFlutterFire ?? Geoflutterfire();
  }

  static Network getInstance(
      {Firestore firestore, Geoflutterfire geoFlutterFire}) {
    _network ??=
        Network._(firestore: firestore, geoFlutterFire: geoFlutterFire);
    return _network;
  }
}
