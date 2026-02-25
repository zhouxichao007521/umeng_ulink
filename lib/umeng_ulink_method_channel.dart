import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'umeng_ulink_platform_interface.dart';
import 'src/umeng_ulink_config.dart';

/// An implementation of [UmengUlinkPlatform] that uses method channels.
class MethodChannelUmengUlink extends UmengUlinkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('umeng_ulink');

  void Function(Map<String, dynamic>)? _linkHandler;

  MethodChannelUmengUlink() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLinkReceived':
        if (_linkHandler != null && call.arguments != null) {
          final Map<String, dynamic> params =
              Map<String, dynamic>.from(call.arguments);
          _linkHandler!(params);
        }
        break;
      default:
        debugPrint('UmengUlink: Unhandled method ${call.method}');
    }
  }

  @override
  Future<void> init(UmengUlinkConfig config) async {
    await methodChannel.invokeMethod('init', config.toJson());
  }

  @override
  Future<Map<String, dynamic>?> getInstallParams() async {
    final result =
        await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getInstallParams');
    if (result == null) return null;
    return Map<String, dynamic>.from(result);
  }

  @override
  void setLinkHandler(void Function(Map<String, dynamic>)? handler) {
    _linkHandler = handler;
  }

  @override
  Future<String?> getSdkVersion() async {
    return await methodChannel.invokeMethod<String>('getSdkVersion');
  }
}
