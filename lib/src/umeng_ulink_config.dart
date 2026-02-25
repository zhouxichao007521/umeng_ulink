/// 友盟 U-Link 初始化配置
class UmengUlinkConfig {
  /// Android AppKey（在友盟后台获取）
  final String androidAppKey;

  /// iOS AppKey（在友盟后台获取）
  final String iosAppKey;

  /// 是否开启调试模式
  final bool debugMode;

  /// 渠道名称（可选）
  final String? channel;

  /// 是否使用剪切板匹配（Android）
  /// 默认为 true，如果不需要剪切板功能可设为 false
  final bool clipboardEnabled;

  const UmengUlinkConfig({
    required this.androidAppKey,
    required this.iosAppKey,
    this.debugMode = false,
    this.channel,
    this.clipboardEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'androidAppKey': androidAppKey,
      'iosAppKey': iosAppKey,
      'debugMode': debugMode,
      'channel': channel ?? '',
      'clipboardEnabled': clipboardEnabled,
    };
  }

  factory UmengUlinkConfig.fromJson(Map<String, dynamic> json) {
    return UmengUlinkConfig(
      androidAppKey: json['androidAppKey'] as String,
      iosAppKey: json['iosAppKey'] as String,
      debugMode: json['debugMode'] as bool? ?? false,
      channel: json['channel'] as String?,
      clipboardEnabled: json['clipboardEnabled'] as bool? ?? true,
    );
  }
}
