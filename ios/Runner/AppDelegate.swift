import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let batteryChannelName = "background_location_tracker/battery"
  private let getBatteryMethod = "getBatteryLevel"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: batteryChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == self?.getBatteryMethod else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.getBatteryLevel(result: result)
    }
  }

  private func getBatteryLevel(result: FlutterResult) {
    #if targetEnvironment(simulator)
    // The iOS Simulator does not expose a real battery.
    result(100)
    return
    #endif

    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel

    guard batteryLevel >= 0 else {
      result(
        FlutterError(
          code: "UNAVAILABLE",
          message: "Battery level is unavailable.",
          details: nil
        )
      )
      return
    }

    result(Int(batteryLevel * 100))
  }
}
