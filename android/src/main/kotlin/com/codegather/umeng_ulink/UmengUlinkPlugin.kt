package com.codegather.umeng_ulink

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.umeng.commonsdk.UMConfigure
import com.umeng.link.UMLinkAgent
import com.umeng.link.UMLinkCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

/**
 * 友盟 U-Link Flutter 插件
 *
 * 支持功能：
 * - 初始化 SDK
 * - 获取安装参数（延迟深度链接）
 * - 处理深度链接唤醒
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
     * 初始化友盟 U-Link SDK
     */
    private fun initSdk(arguments: Map<*, *>, result: Result) {
        if (isInitialized) {
            result.success(null)
            return
        }

        val appKey = arguments["androidAppKey"] as? String
        val debugMode = arguments["debugMode"] as? Boolean ?: false
        val channel = arguments["channel"] as? String ?: "Flutter"

        if (appKey.isNullOrEmpty()) {
            result.error("INVALID_APPKEY", "androidAppKey cannot be null or empty", null)
            return
        }

        try {
            // 设置日志模式
            UMConfigure.setLogEnabled(debugMode)

            // 初始化友盟 Common SDK
            UMConfigure.init(
                context,
                appKey,
                channel,
                UMConfigure.DEVICE_TYPE_PHONE,
                ""
            )

            // 初始化 U-Link SDK
            UMLinkAgent.getInstance(context).init(object : UMLinkCallback.InitCallback {
                override fun onComplete() {
                    Log.d(TAG, "U-Link SDK initialized successfully")
                    isInitialized = true
                    // 初始化成功后处理深度链接
                    activity?.let { handleDeepLink(it) }
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.e(TAG, "U-Link SDK initialization failed: $errorCode - $errorMsg")
                }
            })

            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize U-Link SDK", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    /**
     * 获取安装参数（延迟深度链接）
     */
    private fun getInstallParams(result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "U-Link SDK is not initialized", null)
            return
        }

        try {
            UMLinkAgent.getInstance(context).getInstallParams(object : UMLinkCallback.InstallCallback {
                override fun onResult(params: MutableMap<String, String>?) {
                    if (params != null && params.isNotEmpty()) {
                        Log.d(TAG, "Install params: $params")
                        result.success(params)
                    } else {
                        Log.d(TAG, "No install params found")
                        result.success(null)
                    }
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.e(TAG, "Failed to get install params: $errorCode - $errorMsg")
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
     */
    private fun handleDeepLink(activity: Activity) {
        val intent = activity.intent
        if (intent != null && intent.data != null) {
            Log.d(TAG, "Handling deep link: ${intent.data}")
            UMLinkAgent.getInstance(context).handleDeepLink(intent, object : UMLinkCallback.DeepLinkCallback {
                override fun onResult(params: MutableMap<String, String>?) {
                    if (params != null && params.isNotEmpty()) {
                        Log.d(TAG, "Deep link params: $params")
                        channel.invokeMethod("onLinkReceived", params)
                    }
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.e(TAG, "Failed to handle deep link: $errorCode - $errorMsg")
                }
            })
        }
    }

    /**
     * 获取 SDK 版本
     */
    private fun getSdkVersion(): String {
        return try {
            // 友盟 SDK 版本
            "U-Link 1.3.0"
        } catch (e: Exception) {
            "Unknown"
        }
    }

    // ActivityAware callbacks
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener { intent ->
            intent?.let {
                activity?.intent = it
                if (isInitialized) {
                    handleDeepLink(activity!!)
                }
            }
            true
        }
        // 如果已经初始化，处理当前的深度链接
        if (isInitialized) {
            handleDeepLink(activity!!)
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
    }
}
