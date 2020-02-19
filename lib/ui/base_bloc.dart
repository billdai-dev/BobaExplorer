import 'dart:async';

import 'package:boba_explorer/ui/event.dart';
import 'package:rxdart/rxdart.dart';

class BaseBloc {
  final PublishSubject<Event> _eventStreamController = PublishSubject();

  StreamSink<Event> get eventSink => _eventStreamController.sink;

  Stream<Event> get eventStream => _eventStreamController.stream;

  void dispose() {
    _eventStreamController.close();
  }
}
