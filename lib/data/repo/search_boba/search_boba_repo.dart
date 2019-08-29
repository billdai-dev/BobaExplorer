import 'package:boba_explorer/data/repo/base_repo.dart';

abstract class SearchBobaRepoContract {
  Future<List<String>> getRecentSearch();

  Future<bool> addRecentSearch(String shop);
}

class SearchBobaRepo extends BaseRepo implements SearchBobaRepoContract {
  @override
  Future<List<String>> getRecentSearch() {
    return localStorage.loadRecentSearch();
  }

  @override
  Future<bool> addRecentSearch(String shop) {
    return localStorage.saveRecentSearch(shop);
  }
}
