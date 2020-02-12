abstract class ISearchBobaRepository {
  Future<List<String>> getRecentSearch();

  Future<bool> addRecentSearch(String shop);
}
