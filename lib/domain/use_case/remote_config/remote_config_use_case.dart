import 'package:boba_explorer/domain/entity/supported_shop.dart';
import 'package:boba_explorer/domain/repository/remote_config/remote_config_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/service/device/device_info_use_case.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class GetSupportedShopUseCase extends UseCase<List<SupportedShop>> {
  final IRemoteConfigRepository _remoteConfigRepository;

  GetSupportedShopUseCase(
      this._remoteConfigRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _remoteConfigRepository.getSupportedShop();
  }
}

class CheckAppVersionUseCase extends UseCase<CheckAppVersionResponse> {
  final GetAppVersionUseCase _getAppVersionUseCase;
  final IRemoteConfigRepository _remoteConfigRepository;

  CheckAppVersionUseCase(this._getAppVersionUseCase,
      this._remoteConfigRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture() {
    return _getAppVersionUseCase.execute().then((appVersionStream) {
      return appVersionStream.asyncMap((currentVersion) =>
          _remoteConfigRepository.checkAppVersion(currentVersion));
    });
  }
}

class CheckAppVersionResponse {
  bool _shouldUpdate;
  bool _forceUpdate;
  String _version;
  String _requiredVersion;

  CheckAppVersionResponse.noUpdates(this._version)
      : _shouldUpdate = false,
        _forceUpdate = false;

  CheckAppVersionResponse.forceUpdate(this._version, this._requiredVersion)
      : _shouldUpdate = true,
        _forceUpdate = true;

  CheckAppVersionResponse.suggestUpdate(this._version, this._requiredVersion)
      : _shouldUpdate = true,
        _forceUpdate = false;

  String get version => _version;

  bool get forceUpdate => _forceUpdate;

  bool get shouldUpdate => _shouldUpdate;

  String get requiredVersion => _requiredVersion;
}
