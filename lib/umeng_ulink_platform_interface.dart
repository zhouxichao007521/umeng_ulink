import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'umeng_ulink_method_channel.dart';
import 'src/umeng_ulink_config.dart';

abstract class UmengUlinkPlatform extends PlatformInterface {
  /// Constructs a UmengUlinkPlatform.
  UmengUlinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static UmengUlinkPlatform _instance = MethodChannelUmengUlink();

  /// The default instance of [UmengUlinkPlatform] to use.
  ///
  /// Defaults to [MethodChannelUmengUlink].
  static UmengUlinkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UmengUlinkPlatform] when
  /// they register themselves.
  static set instance(UmengUlinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化 SDK
  Future<void> init(UmengUlinkConfig config) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// 获取安装参数
  Future<Map<String, dynamic>?> getInstallParams() {
    throw UnimplementedError('getInstallParams() has not been implemented.');
  }

  /// 设置深度链接回调
  void setLinkHandler(void Function(Map<String, dynamic>)? handler) {
    throw UnimplementedError('setLinkHandler() has not been implemented.');
  }

  /// 获取 SDK 版本
  Future<String?> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }
}
