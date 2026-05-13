import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // TODO(user): replace YOUR_GOOGLE_MAPS_API_KEY with a real key from
    // Google Cloud Console (enable Maps SDK for iOS).
    GMSServices.provideAPIKey("AIzaSyAq4pOr7whQmtoQJ-hrkjvW8Zj5IYSx8ug")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}