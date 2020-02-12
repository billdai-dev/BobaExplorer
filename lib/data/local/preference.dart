import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

abstract class IPreference {
  Future<List<String>> loadRecentSearch();

  Future<bool> saveRecentSearch(String shopName);
}

class Preference implements IPreference {
  static const _keyRecentSearch = "recentSearch";

  Completer<SharedPreferences> _pref = Completer();

  Preference() {
    _pref.complete(SharedPreferences.getInstance());
  }

  @override
  Future<List<String>> loadRecentSearch() {
    return _pref.future.then((pref) => pref.getStringList(_keyRecentSearch));
  }

  @override
  Future<bool> saveRecentSearch(String shopName) async {
    final pref = await _pref.future;
    List<String> recentSearch = pref.getStringList(_keyRecentSearch) ?? [];
    recentSearch
      ..remove(shopName)
      ..insert(0, shopName);
    while (recentSearch.length > 5) {
      recentSearch.removeLast();
    }
    return pref.setStringList(_keyRecentSearch, recentSearch);
  }
}
