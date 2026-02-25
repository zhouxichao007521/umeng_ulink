library umeng_ulink;

import 'src/umeng_ulink_api.dart';
import 'src/umeng_ulink_config.dart';

export 'src/umeng_ulink_api.dart';
export 'src/umeng_ulink_config.dart';

/// 友盟 U-Link 深度链接 SDK
///
/// 用于处理深度链接、延迟深度链接、邀请归因等功能
///
/// ## 使用示例
///
/// ```dart
/// // 初始化
/// await UmengUlink.init(
///   androidAppKey: 'your_android_appkey',
///   iosAppKey: 'your_ios_appkey',
/// );
///
/// // 获取安装参数（延迟深度链接）
/// final params = await UmengUlink.getInstallParams();
/// if (params != null) {
///   final inviteCode = params['invite_code'];
///   // 处理邀请码
/// }
///
/// // 监听深度链接回调
/// UmengUlink.onLinkReceived((params) {
///   // 处理深度链接参数
/// });
/// ```
class UmengUlink {
  UmengUlink._();

  static final UmengUlinkApi _api = UmengUlinkApi();

  /// 初始化友盟 U-Link SDK
  ///
  /// [config] 初始化配置
  ///
  /// 必须在用户同意隐私政策后调用
  static Future<void> init(UmengUlinkConfig config) {
    return _api.init(config);
  }

  /// 获取首次安装参数（延迟深度链接）
  ///
  /// 返回通过深度链接传递的参数，如邀请码、渠道等
  /// 如果用户不是通过深度链接安装的，返回 null
  ///
  /// 建议在用户同意隐私政策后延迟 1-2 秒再调用
  static Future<Map<String, dynamic>?> getInstallParams() {
    return _api.getInstallParams();
  }

  /// 监听深度链接回调
  ///
  /// 当 App 被深度链接唤醒时触发
  /// [callback] 回调函数，接收深度链接参数
  static void onLinkReceived(void Function(Map<String, dynamic>) callback) {
    _api.onLinkReceived(callback);
  }

  /// 移除深度链接监听
  static void removeLinkListener() {
    _api.removeLinkListener();
  }

  /// 获取 SDK 版本
  static Future<String?> getSdkVersion() {
    return _api.getSdkVersion();
  }
}
