import 'package:boba_explorer/ui/event.dart';

class UpdateAppEvent extends Event {
  final bool _isForceUpdate;
  final String _requiredAppVersion;

  UpdateAppEvent(this._isForceUpdate, this._requiredAppVersion);

  String get requiredAppVersion => _requiredAppVersion;

  bool get isForceUpdate => _isForceUpdate;
}

class RemindRatingEvent extends Event {}
