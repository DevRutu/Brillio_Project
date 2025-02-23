import UIKit
import Flutter
import GoogleMaps // Import the GoogleMaps module

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add your Google Maps API key here
    

    // Register plugins with the Flutter framework
    GeneratedPluginRegistrant.register(with: self)

    // Call the superclass method
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}