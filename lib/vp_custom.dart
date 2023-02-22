
import 'vp_custom_platform_interface.dart';

class VpCustom {
  Future<dynamic> play(Map<String,dynamic> data) {
    return VpCustomPlatform.instance.play(data);
  }

  Future<dynamic> customPlayer(Map<String,dynamic> data) {
    return VpCustomPlatform.instance.customPlayer(data);
  }
}
