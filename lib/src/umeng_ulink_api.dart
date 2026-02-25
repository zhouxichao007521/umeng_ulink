import '../umeng_ulink_platform_interface.dart';
import 'umeng_ulink_config.dart';

/// 友盟 U-Link API 实现
class UmengUlinkApi {
  /// 初始化 SDK
  Future<void> init(UmengUlinkConfig config) async {
    await UmengUlinkPlatform.instance.init(config);
  }

  /// 获取安装参数
  Future<Map<String, dynamic>?> getInstallParams() async {
    return await UmengUlinkPlatform.instance.getInstallParams();
  }

  /// 设置深度链接回调
  void onLinkReceived(void Function(Map<String, dynamic>) callback) {
    UmengUlinkPlatform.instance.setLinkHandler(callback);
  }

  /// 移除深度链接监听
  void removeLinkListener() {
    UmengUlinkPlatform.instance.setLinkHandler(null);
  }

  /// 获取 SDK 版本
  Future<String?> getSdkVersion() async {
    return await UmengUlinkPlatform.instance.getSdkVersion();
  }
}
