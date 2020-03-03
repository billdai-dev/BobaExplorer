import 'dart:async';

import 'package:boba_explorer/domain/use_case/search/search_use_case.dart';
import 'package:boba_explorer/domain/use_case/tea_shop/tea_shop_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:rxdart/rxdart.dart';

class SearchBobaBloc extends BaseBloc {
  final GetRecentSearchUseCase _getRecentSearchUseCase;
  final AddRecentSearchUseCase _addRecentSearchUseCase;
  final FindTeaShopUseCase _findTeaShopUseCase;

  final BehaviorSubject<List<String>> _recentSearchController =
      BehaviorSubject();

  Stream<List<String>> get recentSearch => _recentSearchController.stream;

  SearchBobaBloc(this._getRecentSearchUseCase, this._addRecentSearchUseCase,
      this._findTeaShopUseCase) {
    _getRecentSearchUseCase.execute().then((searchResultStream) =>
        searchResultStream.listen(_recentSearchController.add));
  }

  @override
  void dispose() {
    super.dispose();
    _recentSearchController?.close();
  }

  void addRecentSearch(String shop) {
    _addRecentSearchUseCase.execute(shop);
  }

  Future<List<TeaShop>> searchTeaShop(String name,
      {double lat, double lng, double radius}) {
    return _findTeaShopUseCase
        .execute(FindTeaShopParam(lat, lng, radius: radius, shopNames: {name}))
        .then((teaShopsStream) => teaShopsStream.first);
  }
}
