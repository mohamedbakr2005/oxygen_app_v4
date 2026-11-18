import Flutter
import UIKit
import app_links
import FBSDKCoreKit
import GoogleSignIn

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Capture cold-start Universal Links before Flutter finishes initializing so
    // AppLinks.shared.getInitialLink() always receives them under UIScene.
    for userActivity in connectionOptions.userActivities {
      if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
         let url = userActivity.webpageURL {
        AppLinks.shared.handleLink(url: url)
        break
      }
    }

    // Capture cold-start custom URL schemes (OAuth callbacks or oxygenmart:// deep links).
    if !connectionOptions.urlContexts.isEmpty {
      handleIncomingURLContexts(connectionOptions.urlContexts)
    }

    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      AppLinks.shared.handleLink(url: url)
    }

    super.scene(scene, continue: userActivity)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    handleIncomingURLContexts(URLContexts)
    super.scene(scene, openURLContexts: URLContexts)
  }

  private func handleIncomingURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
    for urlContext in urlContexts {
      let url = urlContext.url

      var options: [UIApplication.OpenURLOptionsKey: Any] = [
        .openInPlace: urlContext.options.openInPlace
      ]
      if let sourceApp = urlContext.options.sourceApplication {
        options[.sourceApplication] = sourceApp
      }
      if let annotation = urlContext.options.annotation {
        options[.annotation] = annotation
      }

      if ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        options: options
      ) {
        continue
      }

      if GIDSignIn.sharedInstance.handle(url) {
        continue
      }

      AppLinks.shared.handleLink(url: url)
    }
  }
}
