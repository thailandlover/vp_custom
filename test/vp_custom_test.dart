import 'package:flutter_test/flutter_test.dart';
import 'package:vp_custom/vp_custom.dart';
import 'package:vp_custom/vp_custom_platform_interface.dart';
import 'package:vp_custom/vp_custom_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVpCustomPlatform
    with MockPlatformInterfaceMixin
    implements VpCustomPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VpCustomPlatform initialPlatform = VpCustomPlatform.instance;

  test('$MethodChannelVpCustom is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVpCustom>());
  });

  test('getPlatformVersion', () async {
    VpCustom vpCustomPlugin = VpCustom();
    MockVpCustomPlatform fakePlatform = MockVpCustomPlatform();
    VpCustomPlatform.instance = fakePlatform;

    expect(await vpCustomPlugin.getPlatformVersion(), '42');
  });
}
