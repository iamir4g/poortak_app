import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var secureField: UITextField?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let securityChannel = FlutterMethodChannel(
        name: "poortak.security.flutter.dev/channel",
        binaryMessenger: controller.binaryMessenger
      )

      securityChannel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "setSecureFlag":
          let enable = (call.arguments as? [String: Any])?["enable"] as? Bool ?? false
          DispatchQueue.main.async {
            if enable {
              self?.enableScreenSecurity()
            } else {
              self?.disableScreenSecurity()
            }
          }
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func enableScreenSecurity() {
    guard secureField == nil, let window = window else { return }

    let field = UITextField()
    field.isSecureTextEntry = true
    field.isUserInteractionEnabled = false
    field.translatesAutoresizingMaskIntoConstraints = false
    window.addSubview(field)
    NSLayoutConstraint.activate([
      field.centerXAnchor.constraint(equalTo: window.centerXAnchor),
      field.centerYAnchor.constraint(equalTo: window.centerYAnchor),
      field.widthAnchor.constraint(equalToConstant: 1),
      field.heightAnchor.constraint(equalToConstant: 1),
    ])

    window.layer.superlayer?.addSublayer(field.layer)
    field.layer.sublayers?.last?.addSublayer(window.layer)
    secureField = field
  }

  private func disableScreenSecurity() {
    secureField?.removeFromSuperview()
    secureField = nil
  }
}
