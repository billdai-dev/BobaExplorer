import 'dart:async';

import 'package:boba_explorer/app_event.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:rxdart/rxdart.dart';

class BaseBloc {
  final PublishSubject<Event> _eventStreamController = PublishSubject();

  StreamSink<Event> get eventSink => _eventStreamController.sink;

  Stream<Event> get eventStream => _eventStreamController.stream;

  Stream<ChangeLoadingEvent> get loadingEventStream =>
      _eventStreamController.stream
          .where((event) => event is ChangeLoadingEvent)
          .cast<ChangeLoadingEvent>();

  void dispose() {
    _eventStreamController.close();
  }
}
