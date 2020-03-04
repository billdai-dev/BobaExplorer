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

    buildUseCaseFuture().then((value) {
      if (value is Stream) {
        _sub = value.listen((val) {
          if (!_sc.isClosed) {
            _sc.add(val);
          }
        }, onError: (e) {
          if (!_sc.isClosed) {
            _sc.addError(_exceptionHandler.parse(e));
          }
        });
      } else {
        _sc.add(value);
      }
    }).catchError((e) {
      if (!_sc.isClosed) {
        _sc.addError(_exceptionHandler.parse(e));
      }
    });
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture();
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

    buildUseCaseFuture(param).then((value) {
      if (value is Stream) {
        _sub = value.listen((val) {
          if (!_sc.isClosed) {
            _sc.add(val);
          }
        }, onError: (e) {
          if (!_sc.isClosed) {
            _sc.addError(_exceptionHandler.parse(e));
          }
        });
      } else {
        _sc.add(value);
      }
    }).catchError((e) {
      if (!_sc.isClosed) {
        _sc.addError(_exceptionHandler.parse(e));
      }
    });
    /*.whenComplete(() {
      return _sc.close();
    });*/
    return _sc.stream;
  }

  @protected
  Future buildUseCaseFuture(P param);
}
