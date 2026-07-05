package com.kynos.kynos

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "kynos/device_thermal",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isThermallyThrottled" -> {
                    val powerManager =
                        getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(powerManager.isPowerSaveMode)
                }
                else -> result.notImplemented()
            }
        }
    }
}
