import Flutter
import KeychainAccess
import RealmSwift
import UIKit

public class SwiftDataImporterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "data_importer", binaryMessenger: registrar.messenger())
    let instance = SwiftDataImporterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getUser" {
      let userName = UserDefaults.standard.string(forKey: "username")

      if userName != nil {
        let keychain = Keychain(service: "org.openfoodfacts.openfoodfacts")
        result(["user": userName, "password": keychain[userName!]])
      } else {
        result(["user": nil, "password": nil])
      }
    } else if call.method == "getHistory" {
      configureRealm()

      result(
        Array(getRealm().objects(HistoryItem.self).sorted(byKeyPath: "timestamp", ascending: false))
          .map { $0.barcode })
    } else if call.method == "clearOldData" {
      UserDefaults.standard.removeObject(forKey: "username")
      do {
        try Keychain(service: "org.openfoodfacts.openfoodfacts").removeAll()

        let url = Realm.Configuration.defaultConfiguration.fileURL!
        remove(realmURL: url)
        result(true)
      } catch {
        result(false)
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func remove(realmURL: URL) {
          let realmURLs = [
              realmURL,
              realmURL.appendingPathExtension("lock"),
              realmURL.appendingPathExtension("note"),
              realmURL.appendingPathExtension("management"),
              ]
          for URL in realmURLs {
              try? FileManager.default.removeItem(at: URL)
          }
  }

  private func configureRealm() {
    // https://stackoverflow.com/questions/33363508/rlmexception-migration-is-required-for-object-type
    let config = Realm.Configuration(
      schemaVersion: 36,
      // Set the block which will be called automatically when opening a Realm with
      // a schema version lower than the one set above
      migrationBlock: { _, oldSchemaVersion in
        // Whenever your scheme changes your have to increase the schemaVersion in the migration block and update the needed migration within the block.
        if oldSchemaVersion < 36 {
          // Nothing to do!
          // Realm will automatically detect new properties and removed properties
          // And will update the schema on disk automatically
        }
      })

    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config

    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    do {
      _ = try Realm(configuration: config)
      print("AppDelegate: Database Path : \(config.fileURL!)")
    } catch {
      print(error.localizedDescription)
    }
  }

  private func getRealm() -> Realm {
    do {
      return try Realm()
    } catch let error as NSError {
      fatalError("Could not get Realm instance")
    }
    fatalError("Could not get Realm instance")
  }
}

class HistoryItem: Object {
  @objc dynamic var barcode = ""
  @objc dynamic var productName: String?
  @objc dynamic var brand: String?
  @objc dynamic var quantity: String?
  @objc dynamic var packaging: String?
  @objc dynamic var labels: String?
  @objc dynamic var imageUrl: String?
  @objc dynamic var timestamp = Date()
  @objc dynamic var nutriscore: String?
  @objc dynamic var ecoscore: String?
  let novaGroup = RealmOptional<Int>()

  override static func primaryKey() -> String? {
    return "barcode"
  }
}