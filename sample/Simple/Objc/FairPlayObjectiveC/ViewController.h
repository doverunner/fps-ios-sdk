//
//  ViewController.h
//  DoveRunnerFairPlayObjC
//
//  Created by DRM Team on 2018. 4. 5..
//  Copyright © 2018년 DoveRunner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

#if TARGET_OS_IOS
#import <DoveRunnerFairPlay/DoveRunnerFairPlay-ObjC.h>
#else
#import <DoveRunnerFairPlayTV/DoveRunnerFairPlayTV-ObjC.h>
#endif


@interface ViewController : UIViewController <FairPlayLicenseDelegate>

@property (strong, nonatomic) DoveRunnerFairPlay *doverunnerSdk;

@end

