//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DRM Team
//
//  SceneDelegate
//
//  Owns the window and the root view hierarchy for one UI scene.
//  Google Cast step 2 happens here: the app's navigation stack is wrapped in a
//  `GCKUICastContainerViewController` so the mini media controller can be shown
//  at the bottom of every screen while a Cast session is active.
//

import UIKit
import GoogleCast

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    /// The Cast container that hosts the app's navigation controller.
    /// `nil` until `scene(_:willConnectTo:options:)` has run.
    var castContainerViewController: GCKUICastContainerViewController? {
        return window?.rootViewController as? GCKUICastContainerViewController
    }

    // MARK: UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // The storyboard is not assigned in the scene manifest on purpose:
        // the root view controller has to be wrapped in the Cast container
        // before it is attached to the window, so it is built here in code.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigation")
        
        // Google Cast step 2.
        // `GCKUICastContainerViewController` embeds the content view controller
        // and manages the mini media controls. It requires `GCKCastContext` to be
        // initialized already (see `AppDelegate.setupGoogleCast()`).
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
        castContainerVC.miniMediaControlsItemEnabled = true
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = castContainerVC
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
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

// MARK: - Google Cast mini media controls

extension SceneDelegate {
    /// Whether the mini media controller is shown at the bottom of the container.
    var castControlBarsEnabled: Bool {
        return castContainerViewController?.miniMediaControlsItemEnabled ?? false
    }
    
    /// Shows or hides the mini media controller. The sample hides it right before
    /// presenting the expanded controls so the two do not overlap.
    func setCastControlBarsEnabled(_ enabled: Bool) {
        castContainerViewController?.miniMediaControlsItemEnabled = enabled
    }
}

// MARK: - Scene lookup helper

extension UIResponder {
    /// Resolves the `SceneDelegate` that owns the window this responder is in.
    /// Prefer this over `UIApplication.shared.delegate` for anything window-related;
    /// in a scene-based app the app delegate no longer owns a window.
    var sceneDelegate: SceneDelegate? {
        if let viewController = self as? UIViewController {
            return viewController.view.window?.windowScene?.delegate as? SceneDelegate
        }
        if let view = self as? UIView {
            return view.window?.windowScene?.delegate as? SceneDelegate
        }
        return nil
    }
}
