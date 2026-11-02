//
//  AppDelegate.m
//  DoveRunnerFairPlayObjC
//
//  Created by DRM Team on 2018. 4. 5..
//  Copyright © 2018년 DoveRunner. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // "Default Configuration" is declared in Info.plist (UIApplicationSceneManifest)
    // and points to `SceneDelegate` and the Main storyboard.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate.
}


@end
