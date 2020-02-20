import 'package:boba_explorer/domain/service/device/device_manager.dart';
import 'package:package_info/package_info.dart';

class DeviceManager implements IDeviceManager {
  @override
  Future<String> getAppVersion() {
    return PackageInfo.fromPlatform().then((info) => info.version);
  }
}
