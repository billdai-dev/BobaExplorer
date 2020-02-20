import 'package:boba_explorer/domain/service/device/device_manager.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class GetAppVersionUseCase extends UseCase<String> {
  final IDeviceManager _deviceManager;

  GetAppVersionUseCase(this._deviceManager, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _deviceManager.getAppVersion();
  }
}

class CheckRatingReminderUseCase extends UseCase<bool> {
  final IDeviceManager _deviceManager;

  CheckRatingReminderUseCase(
      this._deviceManager, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _deviceManager.shouldRemindRating();
  }
}

class AnswerRatingReminderUseCase extends ParamUseCase<bool, void> {
  final IDeviceManager _deviceManager;

  AnswerRatingReminderUseCase(
      this._deviceManager, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(bool rated) {
    return _deviceManager.answerRatingReminder(rated);
  }
}
