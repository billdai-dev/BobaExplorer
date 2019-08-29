import 'dart:async';

import 'package:boba_explorer/data/moor_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyRecentSearch = "recentSearch";

  static LocalStorage _localStorage;

  Completer<SharedPreferences> _pref;

  //Future<SharedPreferences> get pref => _pref.future;

  BobaDatabase _db;

  LocalStorage._({Future<SharedPreferences> pref, BobaDatabase db}) {
    _pref = Completer();
    var prefFuture = pref ?? SharedPreferences.getInstance();
    prefFuture.then((pref) => _pref.complete(pref));
    _db = db ?? BobaDatabase();
  }

  static LocalStorage getInstance(
      {Future<SharedPreferences> pref, BobaDatabase db}) {
    _localStorage ??= LocalStorage._(pref: pref, db: db);
    return _localStorage;
  }

  Stream<List<FavoriteShop>> loadFavoriteShops() {
    return _db.watchFavoriteShops();
  }

  Future<void> setFavoriteShops(bool isFavorite, FavoriteShop shop) {
    if (isFavorite) {
      return _db.addFavoriteShop(shop);
    }
    return _db.deleteFavoriteShop(shop.docId);
  }

  Future<List<String>> loadRecentSearch() {
    return _pref.future.then((pref) => pref.getStringList(_keyRecentSearch));
  }

  Future<bool> saveRecentSearch(String shop) async {
    final pref = await _pref.future;
    List<String> recentSearch = pref.getStringList(_keyRecentSearch) ?? [];
    recentSearch
      ..remove(shop)
      ..insert(0, shop);
    return pref.setStringList(_keyRecentSearch, recentSearch);
  }
}
