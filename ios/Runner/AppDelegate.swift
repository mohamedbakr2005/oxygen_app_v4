import UIKit
import Flutter
import GoogleMaps
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyBaO33dNm_8AyDJFNUN0DD8OngFW2jsUDs")
    
    // Set up Facebook SDK
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle URL callbacks for Google Sign-In & Facebook
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    
    // Handle Facebook URL
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }

    // Handle Google Sign-In URL
    return GIDSignIn.sharedInstance.handle(url)
  }

  // Handle Google Sign-In for iOS 8 and earlier
  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}
