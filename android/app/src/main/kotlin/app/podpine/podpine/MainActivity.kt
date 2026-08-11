package app.podpine.podpine

import com.ryanheise.audioservice.AudioServiceActivity
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
            if (call.method == "availableBytes") {
                result.success(StatFs(filesDir.absolutePath).availableBytes)
            } else {
                result.notImplemented()
            }
        }
    }
}
