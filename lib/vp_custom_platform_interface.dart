import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vp_custom_method_channel.dart';

abstract class VpCustomPlatform extends PlatformInterface {
  /// Constructs a VpCustomPlatform.
  VpCustomPlatform() : super(token: _token);

  static final Object _token = Object();

  static VpCustomPlatform _instance = MethodChannelVpCustom();

  /// The default instance of [VpCustomPlatform] to use.
  ///
  /// Defaults to [MethodChannelVpCustom].
  static VpCustomPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VpCustomPlatform] when
  /// they register themselves.
  static set instance(VpCustomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
