import Flutter
import UIKit

/// 友盟 U-Link Flutter 插件
///
/// 支持功能：
/// - 初始化 SDK
/// - 获取安装参数（延迟深度链接）
/// - 处理深度链接唤醒
public class UmengUlinkPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var isInitialized = false
    private var cachedInstallParams: [String: Any]?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "umeng_ulink", binaryMessenger: registrar.messenger())
        let instance = UmengUlinkPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            if let arguments = call.arguments as? [String: Any] {
                initSdk(arguments: arguments, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments cannot be nil", details: nil))
            }
        case "getInstallParams":
            getInstallParams(result: result)
        case "getSdkVersion":
            result(getSdkVersion())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// 初始化友盟 U-Link SDK
    private func initSdk(arguments: [String: Any], result: @escaping FlutterResult) {
        guard !isInitialized else {
            result(nil)
            return
        }

        let appKey = arguments["iosAppKey"] as? String ?? ""
        let debugMode = arguments["debugMode"] as? Bool ?? false
        let channel = arguments["channel"] as? String ?? "Flutter"

        guard !appKey.isEmpty else {
            result(FlutterError(code: "INVALID_APPKEY", message: "iosAppKey cannot be empty", details: nil))
            return
        }

        // 初始化友盟 Common SDK
        UMConfigure.initWithAppkey(appKey, channel: channel)
        UMConfigure.setLogEnabled(debugMode)

        isInitialized = true
        result(nil)
    }

    /// 获取安装参数（延迟深度链接）
    private func getInstallParams(result: @escaping FlutterResult) {
        if let cached = cachedInstallParams {
            result(cached)
            return
        }

        // 友盟 U-Link 通过 MobClickLinkDelegate 回调获取参数
        // 这里返回 nil，实际参数通过 onLinkReceived 回调获取
        // 如果需要获取安装参数，需要实现 MobClickLinkDelegate
        result(nil)
    }

    /// 获取 SDK 版本
    private func getSdkVersion() -> String {
        return "U-Link 1.2.0"
    }

    /// 处理深度链接参数（由 AppDelegate 调用）
    public func handleLinkParams(_ params: [String: Any]) {
        channel?.invokeMethod("onLinkReceived", arguments: params)
    }

    /// 处理安装参数（由 AppDelegate 调用）
    public func handleInstallParams(_ params: [String: Any]) {
        cachedInstallParams = params
        channel?.invokeMethod("onLinkReceived", arguments: params)
    }
}
