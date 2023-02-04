import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vp_custom/vp_custom_method_channel.dart';

void main() {
  MethodChannelVpCustom platform = MethodChannelVpCustom();
  const MethodChannel channel = MethodChannel('vp_custom');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
