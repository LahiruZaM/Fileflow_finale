import Flutter
import UIKit

public class SwiftSystemSettingsPlugin: NSObject, FlutterPlugin {
  /// Registers the plugin with the Flutter plugin registrar.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "system_settings", binaryMessenger: registrar.messenger())
    let instance = SwiftSystemSettingsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles incoming method calls from the Flutter side.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      openSettings() // Call the method to open the device settings.
  }

  /// Opens the system settings of the iOS device.
  private func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) { // URL for the system settings page.
        if #available(iOS 10.0, *) {
            // For iOS 10.0 and above, use the open method with options.
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // For iOS versions below 10.0, use the openURL method.
            UIApplication.shared.openURL(url)
        }
    }
  }
}
