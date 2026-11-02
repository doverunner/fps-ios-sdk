//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DRM Team
//
//  AppDelegate
//
//  Handles process-level events only. Window / view hierarchy setup lives in
//  `SceneDelegate` because apps built with the iOS 27 SDK must adopt the
//  UIScene life cycle.
//
//  Google Cast integration (overview)
//  ┌────────────────────────────┬────────────────────────────────────────────────────┐
//  │ Where                      │ What                                               │
//  ├────────────────────────────┼────────────────────────────────────────────────────┤
//  │ AppDelegate (this file)    │ 1. Initialize GCKCastContext once per process       │
//  │ SceneDelegate              │ 2. Wrap the root VC in GCKUICastContainerViewController │
//  │ BasicTableViewController   │ 3. Show GCKUICastButton, load media to the receiver │
//  │ Info.plist                 │ NSBonjourServices / NSLocalNetworkUsageDescription   │
//  └────────────────────────────┴────────────────────────────────────────────────────┘
//

import UIKit
import GoogleCast

// MARK: - Google Cast configuration

/// Receiver application ID registered on the Google Cast SDK Developer Console.
/// A custom receiver is required to play DRM-protected content with the token
/// passed through `customData`. Replace this value with your own receiver ID.
let applicationID: String = ""

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Stored by `application(_:handleEventsForBackgroundURLSession:completionHandler:)`
    /// and invoked by `FPSPlaybackManager` when the background URL session finishes.
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Google Cast step 1.
        // The Cast context must exist before any Cast UI (GCKUICastButton,
        // GCKUICastContainerViewController) is created. `didFinishLaunching`
        // runs before the first scene connects, so this is the right place.
        setupGoogleCast()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // "Default Configuration" is declared in Info.plist (UIApplicationSceneManifest)
        // and points to `SceneDelegate`.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
}

// MARK: - Google Cast setup

extension AppDelegate {
    /// Google Cast step 1: create the shared `GCKCastContext`.
    ///
    /// Call this exactly once per process. `GCKDiscoveryCriteria` tells the SDK
    /// which receiver application to look for on the local network.
    private func setupGoogleCast() {
        let criteria = GCKDiscoveryCriteria(applicationID: applicationID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        
        // Route Cast SDK logs to the console. Useful while integrating; remove
        // or filter by level for production builds.
        GCKLogger.sharedInstance().delegate = self
    }
}

// MARK: - GCKLoggerDelegate

extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("\(function) \(message)")
    }
}
