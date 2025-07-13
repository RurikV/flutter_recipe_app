import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register custom Bluetooth LE Scanner plugin
    let controller = window?.rootViewController as! FlutterViewController
    BluetoothLeScannerPlugin.register(with: registrar(forPlugin: "BluetoothLeScannerPlugin")!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
