package com.example.fingo

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.expense_tracker/device_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkVersion" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                "isIgnoringBatteryOptimizations" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val packageName = packageName
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent().apply {
                            action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                            data = Uri.parse("package:$packageName")
                        }
                        try {
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            try {
                                startActivity(fallbackIntent)
                                result.success(true)
                            } catch (ex: Exception) {
                                result.error("ERROR", "Failed to open battery settings", ex.message)
                            }
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
