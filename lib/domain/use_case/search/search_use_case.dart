import 'dart:async';

import 'package:boba_explorer/domain/repository/search_boba/search_boba_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class GetRecentSearchUseCase extends UseCase<List<String>> {
  final ISearchBobaRepository _searchBobaRepository;

  GetRecentSearchUseCase(
      this._searchBobaRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(StreamController<List<String>> outputStream) {
    return _searchBobaRepository.getRecentSearch().then(outputStream.add);
  }
}

class AddRecentSearchUseCase extends ParamUseCase<String, bool> {
  final ISearchBobaRepository _searchBobaRepository;

  AddRecentSearchUseCase(
      this._searchBobaRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(String param, StreamController<bool> outputStream) {
    return _searchBobaRepository.addRecentSearch(param).then(outputStream.add);
  }
}
