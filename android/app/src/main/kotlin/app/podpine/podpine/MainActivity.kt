package app.podpine.podpine

import com.ryanheise.audioservice.AudioServiceActivity
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.StatFs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app.podpine.podpine/storage",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "availableBytes" -> result.success(StatFs(filesDir.absolutePath).availableBytes)
                "isCharging" -> {
                    val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    val status = battery?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
                    result.success(
                        status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
