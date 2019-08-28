import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static LocalStorage _localStorage;

  Future<SharedPreferences> _pref;

  Future<SharedPreferences> get pref => _pref;

  LocalStorage._({Future<SharedPreferences> pref}) {
    _pref = pref ?? SharedPreferences.getInstance();
  }

  static LocalStorage getInstance({Future<SharedPreferences> pref}) {
    _localStorage ??= LocalStorage._(pref: pref);
    return _localStorage;
  }
}
