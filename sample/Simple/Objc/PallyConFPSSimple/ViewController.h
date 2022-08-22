//
//  ViewController.h
//  PallyConFPSSimple
//
//  Created by PallyCon on 2018. 4. 5..
//  Copyright © 2018년 inka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

#if TARGET_OS_IOS
#import <PallyConFPSSDK/PallyConFPSSDK-ObjC.h>
#else
#import <PallyConFPSSDKTV/PallyConFPSSDKTV-ObjC.h>
#endif


@interface ViewController : UIViewController <PallyConFPSLicenseDelegate>

@property (strong, nonatomic) PallyConFPSSDK *fpsSDK;

@end

