import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerLaunchHandlers()
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "app.podpine.podpine.backgroundRefresh",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "PodpineStorage"
    ) else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "app.podpine.podpine/storage",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "availableBytes" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let attributes = try FileManager.default.attributesOfFileSystem(
          forPath: NSHomeDirectory()
        )
        let freeBytes = attributes[.systemFreeSize] as? NSNumber
        result(freeBytes?.int64Value)
      } catch {
        result(
          FlutterError(
            code: "storage_unavailable",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }
}
