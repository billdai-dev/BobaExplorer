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
