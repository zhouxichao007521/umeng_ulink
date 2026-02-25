import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umeng_ulink/umeng_ulink_method_channel.dart';
import 'package:umeng_ulink/src/umeng_ulink_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelUmengUlink platform = MethodChannelUmengUlink();
  const MethodChannel channel = MethodChannel('umeng_ulink');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getSdkVersion':
            return '1.0.0';
          case 'getInstallParams':
            return {'invite_code': 'test123', 'family_code': 'family001'};
          case 'init':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getSdkVersion', () async {
    expect(await platform.getSdkVersion(), '1.0.0');
  });

  test('getInstallParams', () async {
    final params = await platform.getInstallParams();
    expect(params, isNotNull);
    expect(params!['invite_code'], 'test123');
    expect(params['family_code'], 'family001');
  });

  test('init', () async {
    const config = UmengUlinkConfig(
      androidAppKey: 'test_android_key',
      iosAppKey: 'test_ios_key',
    );
    // Should not throw
    await platform.init(config);
  });
}
