import 'package:flutter/material.dart';
import 'dart:async';

import 'package:umeng_ulink/umeng_ulink.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sdkVersion = 'Unknown';
  Map<String, dynamic>? _installParams;
  Map<String, dynamic>? _linkParams;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initUlink();
  }

  Future<void> initUlink() async {
    try {
      // 初始化友盟 U-Link SDK
      await UmengUlink.init(
        const UmengUlinkConfig(
          androidAppKey: 'your_android_appkey',
          iosAppKey: 'your_ios_appkey',
          debugMode: true,
        ),
      );

      // 监听深度链接回调
      UmengUlink.onLinkReceived((params) {
        setState(() {
          _linkParams = params;
        });
        debugPrint('Deep link received: $params');
      });

      // 获取 SDK 版本
      final version = await UmengUlink.getSdkVersion();

      // 获取安装参数（建议在隐私政策同意后延迟 1-2 秒调用）
      await Future.delayed(const Duration(seconds: 2));
      final params = await UmengUlink.getInstallParams();

      if (!mounted) return;

      setState(() {
        _sdkVersion = version ?? 'Unknown';
        _installParams = params;
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Failed to init U-Link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('友盟 U-Link 示例'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDK 状态: ${_initialized ? "已初始化" : "初始化中..."}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('SDK 版本: $_sdkVersion'),
              const Divider(),
              const Text(
                '安装参数（延迟深度链接）:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_installParams != null)
                ..._installParams!.entries.map(
                  (e) => Text('  ${e.key}: ${e.value}'),
                )
              else
                const Text('  无安装参数'),
              const Divider(),
              const Text(
                '深度链接参数:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_linkParams != null)
                ..._linkParams!.entries.map(
                  (e) => Text('  ${e.key}: ${e.value}'),
                )
              else
                const Text('  等待深度链接唤醒...'),
            ],
          ),
        ),
      ),
    );
  }
}
