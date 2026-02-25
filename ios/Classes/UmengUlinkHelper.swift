import UIKit

/// 友盟 U-Link AppDelegate 帮助类
///
/// 使用方法：在 AppDelegate.swift 中添加以下代码：
///
/// ```swift
/// import umeng_ulink
///
/// @main
/// @objc class AppDelegate: FlutterAppDelegate {
///     override func application(
///         _ application: UIApplication,
///         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
///     ) -> Bool {
///         // 注册 U-Link Delegate
///         UmengUlinkDelegateHelper.shared.setup()
///
///         GeneratedPluginRegistrant.register(with: self)
///         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
///     }
///
///     // 处理 URL Scheme
///     override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
///         UmengUlinkDelegateHelper.shared.handleOpenURL(url)
///         return super.application(app, open: url, options: options)
///     }
///
///     // 处理 Universal Links
///     override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
///         if let webpageURL = userActivity.webpageURL {
///             UmengUlinkDelegateHelper.shared.handleUniversalLink(webpageURL)
///         }
///         return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
///     }
/// }
/// ```
public class UmengUlinkDelegateHelper: NSObject, MobClickLinkDelegate {

    public static let shared = UmengUlinkDelegateHelper()

    private override init() {
        super.init()
    }

    /// 设置 U-Link Delegate
    public func setup() {
        MobClickLink.shareInstance()?.delegate = self
    }

    /// 处理 URL Scheme
    public func handleOpenURL(_ url: URL) {
        MobClickLink.handleOpenURL(url)
    }

    /// 处理 Universal Links
    public func handleUniversalLink(_ url: URL) {
        MobClickLink.handleUniversalLink(url)
    }

    // MARK: - MobClickLinkDelegate

    /// 深度链接回调
    public func getLinkPath(_ path: String?, params: [AnyHashable: Any]?) {
        guard let params = params as? [String: Any] else { return }

        var result: [String: Any] = [:]
        result["path"] = path ?? ""

        for (key, value) in params {
            if let keyString = key as? String {
                result[keyString] = value
            }
        }

        // 通知 Flutter 端
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: Notification.Name("UmengUlinkLinkReceived"),
                object: nil,
                userInfo: result
            )
        }
    }
}
