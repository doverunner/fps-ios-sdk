//
//  AppDelegate.swift
//  DoveRunnerFairPlayBasicTV
//
//  Created by DRM Team on 2017. 3. 20..
//  Copyright © 2017년 DoveRunner. All rights reserved.
//
//  Handles process-level events only. Window / view hierarchy setup lives in
//  `SceneDelegate` because apps built with the tvOS 27 SDK must adopt the
//  UIScene life cycle.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // "Default Configuration" is declared in Info.plist (UIApplicationSceneManifest)
        // and points to `SceneDelegate` and the Main storyboard.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
