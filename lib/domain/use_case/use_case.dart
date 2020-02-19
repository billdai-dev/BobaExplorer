import 'dart:async';

import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:meta/meta.dart';

abstract class UseCase<R> {
  final IExceptionHandler _exceptionHandler;
  StreamSubscription<R> _sub;

  UseCase(this._exceptionHandler);

  Future<Stream<R>> execute() async {
    final StreamController<R> _sc = StreamController();
    _sc.onCancel = () {
      if (!_sc.isClosed) _sc.close();
    };
    _sub?.cancel();
    _sub = null;

    buildUseCaseFuture(_sc).then((value) {
      if (value is Stream) {
        _sub = value.listen(_sc.add);
      }
    }).catchError((e) {
      if (!_sc.isClosed) {
        _sc.addError(_exceptionHandler.parse(e));
      }
    });
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture(StreamController<R> outputStream);
}

abstract class ParamUseCase<P, R> {
  final IExceptionHandler _exceptionHandler;
  StreamSubscription<R> _sub;

  ParamUseCase(this._exceptionHandler);

  Future<Stream<R>> execute(P param) async {
    final StreamController<R> _sc = StreamController<R>();
    _sc.onCancel = () {
      if (!_sc.isClosed) _sc.close();
    };
    _sub?.cancel();
    _sub = null;

    buildUseCaseFuture(param, _sc).then((value) {
      if (value is Stream) {
        _sub = value.listen(_sc.add);
      }
    }).catchError((e) {
      _sc.addError(_exceptionHandler.parse(e));
    });
    /*.whenComplete(() {
      return _sc.close();
    });*/
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture(P param, StreamController<R> outputStream);
}

/*abstract class WatchUseCase<R> {
  final IExceptionHandler _exceptionHandler;
  StreamSubscription<R> _sub;

  WatchUseCase(this._exceptionHandler);

  Future<Stream<R>> execute() async {
    final StreamController<R> _sc = StreamController();
    _sc.onCancel = () {
      if (!_sc.isClosed) _sc.close();
    };

    _sub?.cancel();
    buildUseCaseFuture().then((stream) {
      _sub = stream.listen(_sc.add);
    }).catchError((e) {
      if (!_sc.isClosed) {
        _sc.addError(_exceptionHandler.parse(e));
      }
    }).whenComplete(() {
      return _sc.close();
    });
    return _sc.stream;
  }

  @protected
  Future<Stream<R>> buildUseCaseFuture();
}*/
