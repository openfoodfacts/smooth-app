import UIKit
import Flutter
import workmanager


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      WorkmanagerPlugin.setPluginRegistrantCallback { registry in
                  // Registry in this case is the FlutterEngine that is created in Workmanager's
                  // performFetchWithCompletionHandler or BGAppRefreshTask.
                  // This will make other plugins available during a background operation.
                  GeneratedPluginRegistrant.register(with: registry)
              }
      
    WorkmanagerPlugin.registerTask(withIdentifier: "BackgroundProcess")
      
    // Every 15 min
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
