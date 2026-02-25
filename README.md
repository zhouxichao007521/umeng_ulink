# umeng_ulink

友盟 U-Link 深度链接 Flutter 插件，支持延迟深度链接、场景还原、邀请归因等功能。

## 功能特性

- ✅ SDK 初始化
- ✅ 获取安装参数（延迟深度链接）
- ✅ 处理深度链接唤醒
- ✅ 支持 Android 和 iOS

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  umeng_ulink:
    git:
      url: https://github.com/CodeGather/umeng_ulink.git
      ref: main
```

## 配置

### Android

1. 在 `android/app/build.gradle` 中添加：

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            UMENG_APPKEY: 'your_android_appkey',
            UMENG_CHANNEL: 'Flutter'
        ]
    }
}
```

2. 在 `AndroidManifest.xml` 中添加（可选，用于 URL Scheme）：

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yolofamily" />
</intent-filter>
```

### iOS

1. 在 `Podfile` 中添加：

```ruby
target 'Runner' do
  # 友盟 U-Link 依赖会自动安装
end
```

2. 在 `Info.plist` 中添加 URL Scheme：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yolofamily</string>
        </array>
    </dict>
</array>
```

3. 在 `AppDelegate.swift` 中添加：

```swift
import umeng_ulink

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 注册 U-Link Delegate
        UmengUlinkDelegateHelper.shared.setup()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 处理 URL Scheme
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        UmengUlinkDelegateHelper.shared.handleOpenURL(url)
        return super.application(app, open: url, options: options)
    }

    // 处理 Universal Links
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let webpageURL = userActivity.webpageURL {
            UmengUlinkDelegateHelper.shared.handleUniversalLink(webpageURL)
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
```

## 使用方法

### 1. 初始化 SDK

```dart
import 'package:umeng_ulink/umeng_ulink.dart';

// 在用户同意隐私政策后调用
await UmengUlink.init(
    const UmengUlinkConfig(
        androidAppKey: 'your_android_appkey',
        iosAppKey: 'your_ios_appkey',
        debugMode: true,
    ),
);
```

### 2. 获取安装参数（延迟深度链接）

```dart
// 建议在隐私政策同意后延迟 1-2 秒调用
await Future.delayed(const Duration(seconds: 2));
final params = await UmengUlink.getInstallParams();

if (params != null) {
    final inviteCode = params['invite_code'];
    final familyCode = params['family_code'];
    // 处理邀请码等参数
}
```

### 3. 监听深度链接回调

```dart
UmengUlink.onLinkReceived((params) {
    // App 被深度链接唤醒时触发
    print('Deep link params: $params');

    // 根据参数跳转到对应页面
    final page = params['page'];
    if (page == 'invite') {
        // 跳转到邀请页面
    }
});
```

### 4. 移除监听

```dart
UmengUlink.removeLinkListener();
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:umeng_ulink/umeng_ulink.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化友盟 U-Link
    await UmengUlink.init(
        const UmengUlinkConfig(
            androidAppKey: 'your_android_appkey',
            iosAppKey: 'your_ios_appkey',
            debugMode: true,
        ),
    );

    // 监听深度链接
    UmengUlink.onLinkReceived((params) {
        print('Deep link: $params');
    });

    runApp(MyApp());
}

class MyApp extends StatefulWidget {
    @override
    State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    Map<String, dynamic>? _installParams;

    @override
    void initState() {
        super.initState();
        _loadInstallParams();
    }

    Future<void> _loadInstallParams() async {
        // 延迟获取安装参数
        await Future.delayed(const Duration(seconds: 2));
        final params = await UmengUlink.getInstallParams();
        setState(() {
            _installParams = params;
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Text('Install params: $_installParams'),
                ),
            ),
        );
    }
}
```

## 注意事项

1. **隐私合规**：必须在用户同意隐私政策后再调用 `init()` 方法
2. **获取安装参数时机**：建议延迟 1-2 秒后再调用 `getInstallParams()`
3. **Universal Links**：iOS 需要配置 `apple-app-site-association` 文件
4. **App Links**：Android 需要配置 `.well-known/assetlinks.json` 文件

## 友盟后台配置

1. 在 [友盟后台](https://message.umeng.com/) 创建应用获取 AppKey
2. 配置 U-Link 深度链接
3. 配置 URL Scheme 和 Universal Links 域名

## License

MIT
