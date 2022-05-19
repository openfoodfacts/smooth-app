import Flutter
import UIKit
import KeychainAccess

public class SwiftDataImporterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "data_importer", binaryMessenger: registrar.messenger())
    let instance = SwiftDataImporterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "getUser") {
          let userName = UserDefaults.standard.string(forKey: "username")

          if (userName != nil){
              let keychain = Keychain(service: "org.openfoodfacts.openfoodfacts")
              result(["user":userName, "password":keychain[userName!]])
          } else {
              result(["user":nil, "password":nil])
          }
      } else if (call.method == "clearOldData") {
          UserDefaults.standard.removeObject(forKey: "username")
          do {
            try Keychain(service: "org.openfoodfacts.openfoodfacts").removeAll()
            result(true)
          } catch {
              result(false)
          }
      } else {
          result(FlutterMethodNotImplemented)
      }
  }
}
