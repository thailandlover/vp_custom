import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vp_custom_platform_interface.dart';

/// An implementation of [VpCustomPlatform] that uses method channels.
class MethodChannelVpCustom extends VpCustomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vp_custom');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
