import 'dart:async';

import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:meta/meta.dart';

abstract class UseCase<R> {
  final IExceptionHandler _exceptionHandler;
  final StreamController<R> _sc = StreamController();

  UseCase(this._exceptionHandler);

  Future<Stream<R>> execute() async {
    buildUseCaseFuture(_sc)
        .catchError((e) => _sc.addError(_exceptionHandler.parse(e)))
        .whenComplete(() => _sc.close());
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture(StreamController<R> outputStream);
}

abstract class ParamUseCase<P, R> {
  final IExceptionHandler _exceptionHandler;
  final StreamController<R> _sc = StreamController<R>();

  ParamUseCase(this._exceptionHandler);

  Future<Stream<R>> execute(P param) async {
    buildUseCaseFuture(param, _sc)
        .catchError((e) => _sc.addError(_exceptionHandler.parse(e)))
        .whenComplete(() => _sc.close());
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture(P param, StreamController<R> outputStream);
}
