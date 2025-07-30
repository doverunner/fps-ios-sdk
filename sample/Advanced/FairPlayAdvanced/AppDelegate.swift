//
//  Copyright © 2017년 INKA ENTWORKS INC. All rights reserved.
//
//  PallyCon Team (http://www.pallycon.com)
//
//  AppDelegate
//

import UIKit
#if os(iOS)
    import GoogleCast
#endif

let kPrefReceiverAppID: String = "receiver_app_id"
let kPrefCustomReceiverSelectedValue: String = "use_custom_receiver_app_id"
let kPrefCustomReceiverAppID: String = "custom_receiver_app_id"

// receive app ID by chromcast
let applicationID: String = ""

let appDelegate = UIApplication.shared.delegate as? AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigation")
        
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: applicationID))
        GCKCastContext.setSharedInstanceWith(options)
        GCKLogger.sharedInstance().delegate = self
        
        let shared = GCKCastContext.sharedInstance()
        let castContainerVC = shared.createCastContainerController(for: navigationController)
        castContainerVC.miniMediaControlsItemEnabled = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = castContainerVC
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func applicationIDFromUserDefaults() -> String {
        let userDefaults = UserDefaults.standard
        var prefApplicationID = userDefaults.string(forKey: kPrefReceiverAppID)
        if prefApplicationID == kPrefCustomReceiverSelectedValue {
            prefApplicationID = userDefaults.string(forKey: kPrefCustomReceiverAppID)
        }
        
        guard let appIdRegex = try? NSRegularExpression(pattern: "\\b[0-9A-F]{8}\\b", options: []),
            let prefAppID = prefApplicationID else {
                return ""
        }
        
        let numberOfMatches = appIdRegex.numberOfMatches(in: prefAppID, options: [], range: NSMakeRange(0, prefAppID.count))
        if numberOfMatches == 0 {
            return ""
        }
        
        return prefAppID
    }
    
    func setCastControlBarsEnabled(notificationsEnabled: Bool) {
        guard let castContainerVC = self.window?.rootViewController as? GCKUICastContainerViewController else {
            return
        }
        castContainerVC.miniMediaControlsItemEnabled = notificationsEnabled
    }
    
    func castControlBarsEnabled() -> Bool {
        guard let castContainerVC = self.window?.rootViewController as? GCKUICastContainerViewController else {
            return false
        }
        return castContainerVC.miniMediaControlsItemEnabled
    }
}

extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("\(function) \(message)")
    }
}

