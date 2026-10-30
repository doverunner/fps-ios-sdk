//
//  SceneDelegate.h
//  DoveRunnerFairPlayObjC
//
//  Copyright © 2025 DoveRunner. All rights reserved.
//
//  Owns the window for one UI scene. The window and root view controller are
//  created by UIKit from the Main storyboard declared in the scene manifest
//  (UISceneStoryboardFile in Info.plist), so nothing has to be built in code here.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
