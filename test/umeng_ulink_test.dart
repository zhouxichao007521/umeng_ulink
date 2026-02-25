import 'package:flutter_test/flutter_test.dart';
import 'package:umeng_ulink/umeng_ulink_platform_interface.dart';
import 'package:umeng_ulink/umeng_ulink_method_channel.dart';
import 'package:umeng_ulink/src/umeng_ulink_config.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUmengUlinkPlatform
    with MockPlatformInterfaceMixin
    implements UmengUlinkPlatform {

  @override
  Future<void> init(UmengUlinkConfig config) => Future.value();

  @override
  Future<Map<String, dynamic>?> getInstallParams() =>
      Future.value({'invite_code': 'test123'});

  @override
  void setLinkHandler(void Function(Map<String, dynamic>)? handler) {}

  @override
  Future<String?> getSdkVersion() => Future.value('1.0.0');
}

void main() {
  final UmengUlinkPlatform initialPlatform = UmengUlinkPlatform.instance;

  test('$MethodChannelUmengUlink is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUmengUlink>());
  });

  test('getSdkVersion', () async {
    MockUmengUlinkPlatform fakePlatform = MockUmengUlinkPlatform();
    UmengUlinkPlatform.instance = fakePlatform;

    expect(await fakePlatform.getSdkVersion(), '1.0.0');
  });

  test('getInstallParams', () async {
    MockUmengUlinkPlatform fakePlatform = MockUmengUlinkPlatform();
    UmengUlinkPlatform.instance = fakePlatform;

    final params = await fakePlatform.getInstallParams();
    expect(params, isNotNull);
    expect(params!['invite_code'], 'test123');
  });
}
