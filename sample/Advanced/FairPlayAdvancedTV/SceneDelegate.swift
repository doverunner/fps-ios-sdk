//
//  SceneDelegate.swift
//  DoveRunnerFairPlayBasicTV
//
//  Copyright © 2017년 DoveRunner. All rights reserved.
//
//  Owns the window for one UI scene. The window and root view controller are
//  created by UIKit from the Main storyboard declared in the scene manifest
//  (UISceneStoryboardFile in Info.plist), so nothing has to be built in code here.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // The window is already configured from the storyboard at this point.
        // Use this method to customize the root view controller if needed.
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused (or not yet started) while the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}
