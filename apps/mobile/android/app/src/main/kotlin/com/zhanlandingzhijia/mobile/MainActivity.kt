package com.zhanlandingzhijia.mobile

import com.alipay.sdk.app.PayTask
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhanlandingzhijia.mobile/alipay_app_pay",
        ).setMethodCallHandler { call, result ->
            if (call.method != "pay") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val orderString = call.argument<String>("orderString")
            if (orderString.isNullOrBlank()) {
                result.error("ALIPAY_ORDER_STRING_MISSING", "支付宝支付参数缺失", null)
                return@setMethodCallHandler
            }

            Thread {
                try {
                    val payResult = PayTask(this).payV2(orderString, true)
                    runOnUiThread { result.success(payResult) }
                } catch (error: Exception) {
                    runOnUiThread {
                        result.error(
                            "ALIPAY_SDK_CALL_FAILED",
                            error.message ?: "支付宝 SDK 调用失败",
                            null,
                        )
                    }
                }
            }.start()
        }
    }
}
