import 'package:boba_explorer/ui/event.dart';

class OnReportedEvent extends Event {
  final bool isSuccess;

  OnReportedEvent(this.isSuccess);
}
