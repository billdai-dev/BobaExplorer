import 'package:boba_explorer/domain/entity/supported_shop.dart';
import 'package:boba_explorer/domain/use_case/remote_config/remote_config_use_case.dart';

abstract class IRemoteConfigRepository {
  Future<List<SupportedShop>> getSupportedShop();

  Future<CheckAppVersionResponse> checkAppVersion(String currentVersion);
}
