import 'dart:async';

import 'package:boba_explorer/domain/entity/supported_shop.dart';
import 'package:boba_explorer/domain/use_case/remote_config/remote_config_use_case.dart';
import 'package:boba_explorer/domain/use_case/service/device/device_info_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc extends BaseBloc {
  final GetSupportedShopUseCase _getSupportedShopUseCase;
  final CheckAppVersionUseCase _checkAppVersionUseCase;
  final CheckRatingReminderUseCase _checkRatingReminderUseCase;
  final AnswerRatingReminderUseCase _answerRatingReminderUseCase;

  final BehaviorSubject<List<SupportedShop>> _supportedShopsController =
      BehaviorSubject();

  Stream<List<SupportedShop>> get supportedShops =>
      _supportedShopsController.stream;

  AppBloc(this._getSupportedShopUseCase, this._checkAppVersionUseCase,
      this._checkRatingReminderUseCase, this._answerRatingReminderUseCase) {
    _getSupportedShopUseCase.execute().then((supportedShopStream) =>
        supportedShopStream.listen(_supportedShopsController.add));
  }

  void checkAppVersion() {
    _checkAppVersionUseCase.execute().then((checkVersionStream) =>
        checkVersionStream.listen((checkVersionResponse) {
          if (!checkVersionResponse.shouldUpdate) {
            checkRatingReminder();
            return;
          }
          bool isForceUpdate = checkVersionResponse.forceUpdate;
          String requiredVersion = checkVersionResponse.requiredVersion;
          eventSink.add(Event.updateApp(isForceUpdate, requiredVersion));
        }));
  }

  void checkRatingReminder() {
    _checkRatingReminderUseCase.execute().then((stream) {
      return stream.listen((shouldRemind) {
        if (shouldRemind) eventSink.add(Event.remindRating());
      });
    });
  }

  void answerRatingReminder(bool rated) {
    _answerRatingReminderUseCase.execute(rated);
  }

  @override
  void dispose() {
    super.dispose();
    _supportedShopsController?.close();
  }
}
