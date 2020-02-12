import 'package:boba_explorer/data/local/preference.dart';
import 'package:boba_explorer/domain/repository/search_boba/search_boba_repository.dart';

class SearchBobaRepo implements ISearchBobaRepository {
  IPreference _preference;

  SearchBobaRepo(this._preference);

  @override
  Future<List<String>> getRecentSearch() {
    return _preference.loadRecentSearch();
  }

  @override
  Future<bool> addRecentSearch(String shop) {
    return _preference.saveRecentSearch(shop);
  }
}
