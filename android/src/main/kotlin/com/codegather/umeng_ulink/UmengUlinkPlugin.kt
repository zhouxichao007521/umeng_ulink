package com.codegather.umeng_ulink

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.umeng.commonsdk.UMConfigure
import com.umeng.umlink.MobclickLink
import com.umeng.umlink.UMLinkListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 友盟 U-Link Flutter 插件
 *
 * 使用 Maven Central 的 com.umeng.umsdk:link（包名 com.umeng.umlink，MobclickLink API）
 * 支持功能：初始化 SDK、获取安装参数（延迟深度链接）、处理深度链接唤醒
 */
class UmengUlinkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    companion object {
        private const val TAG = "UmengUlinkPlugin"
        private const val CHANNEL_NAME = "umeng_ulink"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var isInitialized = false
    private var mobclickLink: MobclickLink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                val arguments = call.arguments as? Map<*, *>
                if (arguments != null) {
                    initSdk(arguments, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Arguments cannot be null", null)
                }
            }
            "getInstallParams" -> {
                getInstallParams(result)
            }
            "getSdkVersion" -> {
                result.success(getSdkVersion())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 初始化友盟 U-Link SDK（Common + MobclickLink）
     */
    private fun initSdk(arguments: Map<*, *>, result: Result) {
        if (isInitialized) {
            result.success(null)
            return
        }

        val appKey = arguments["androidAppKey"] as? String
        val debugMode = arguments["debugMode"] as? Boolean ?: false
        val channelName = arguments["channel"] as? String ?: "Flutter"

        if (appKey.isNullOrEmpty()) {
            result.error("INVALID_APPKEY", "androidAppKey cannot be null or empty", null)
            return
        }

        try {
            UMConfigure.setLogEnabled(debugMode)
            UMConfigure.init(
                context,
                appKey,
                channelName,
                UMConfigure.DEVICE_TYPE_PHONE,
                ""
            )
            val ctx = context ?: run {
                result.error("INIT_ERROR", "Context is null", null)
                return
            }
            mobclickLink = MobclickLink().also { it.init(ctx) }
            isInitialized = true
            Log.d(TAG, "U-Link SDK initialized successfully")
            activity?.let { handleDeepLink(it) }
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize U-Link SDK", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    /**
     * 获取安装参数（延迟深度链接）
     * MobclickLink.getInstallParams(Context, UMLinkListener) -> onInstall / onError
     */
    private fun getInstallParams(result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "U-Link SDK is not initialized", null)
            return
        }
        val ctx = context ?: run {
            result.success(null)
            return
        }
        try {
            MobclickLink.getInstallParams(ctx, object : UMLinkListener {
                override fun onLink(path: String?, params: HashMap<String, String>?) {
                    // 用于 getInstallParams 时不会走 onLink，忽略
                }

                override fun onInstall(params: HashMap<String, String>?, uri: Uri?) {
                    if (params != null && params.isNotEmpty()) {
                        Log.d(TAG, "Install params: $params")
                        result.success(params)
                    } else {
                        result.success(null)
                    }
                }

                override fun onError(msg: String?) {
                    Log.e(TAG, "Failed to get install params: $msg")
                    result.success(null)
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "Error getting install params", e)
            result.success(null)
        }
    }

    /**
     * 处理深度链接唤醒
     * MobclickLink.handleUMLinkURI(Context, Uri, UMLinkListener) -> onLink / onError
     */
    private fun handleDeepLink(activity: Activity) {
        val uri = activity.intent?.data ?: return
        val ctx = context ?: return
        Log.d(TAG, "Handling deep link: $uri")
        MobclickLink.handleUMLinkURI(ctx, uri, object : UMLinkListener {
            override fun onLink(path: String?, params: HashMap<String, String>?) {
                if (params != null && params.isNotEmpty()) {
                    Log.d(TAG, "Deep link params: $params")
                    channel.invokeMethod("onLinkReceived", params)
                }
            }

            override fun onInstall(params: HashMap<String, String>?, uri: Uri?) {}

            override fun onError(msg: String?) {
                Log.e(TAG, "Failed to handle deep link: $msg")
            }
        })
    }

    private fun getSdkVersion(): String {
        return try {
            MobclickLink.getVersion() ?: "U-Link 1.2.0"
        } catch (e: Exception) {
            "U-Link 1.2.0"
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener { intent: Intent? ->
            intent?.let {
                activity?.intent = it
                if (isInitialized) {
                    activity?.let { a -> handleDeepLink(a) }
                }
            }
            true
        }
        if (isInitialized) {
            activity?.let { handleDeepLink(it) }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        mobclickLink = null
    }
}
