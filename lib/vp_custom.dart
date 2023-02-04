
import 'vp_custom_platform_interface.dart';

class VpCustom {
  Future<String?> getPlatformVersion() {
    return VpCustomPlatform.instance.getPlatformVersion();
  }
}
