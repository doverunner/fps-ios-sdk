//
//  ViewController.m
//  DoveRunnerFairPlayObjC
//
//  Created by DRM Team on 2018. 4. 5..
//  Copyright © 2018년 DoveRunner. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

// This is customer-specific information.
// you have to set customer information.
#define CERTIFICATE_URL   @"https://drm-license.doverunner.com/ri/fpsKeyManager.do?siteId=XXXX"
#define CONTENT_ID        @""
#define CONTENT_URL       @""
#define CONTENT_AUTHDATA  @""

@protocol FairPlayLicenseDelegate;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. initialize a DoveRunnerFairPlay SDK.
    _doverunnerSdk = [[DoveRunnerFairPlay alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    NSURL *contentUrl = [NSURL URLWithString:CONTENT_URL];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:contentUrl options:nil];

    // 2. Set parameters required for FPS content playback.
    FairPlayConfiguration* config = [[FairPlayConfiguration alloc] initWithAvURLAsset:urlAsset contentId:CONTENT_ID certificateUrl:CERTIFICATE_URL authData:CONTENT_AUTHDATA delegate:self licenseUrl:nil licenseHttpHeader:nil licenseCookies:nil renewalInterval:0 sendCmcd:false];
    [_doverunnerSdk prepareWithDrm:config];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerViewController *playerController = [AVPlayerViewController new];
    playerController.player = player;
    [self presentViewController:playerController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)licenseWithResult:(LicenseResult *)result {
    NSLog(@"%@",result.contentId);
    if (result.isSuccess == false) {
        NSLog(@"%@", [result getSDKErrorForObjC]);
    }
}

/*
- (NSData *)licenseCallbackWith:(NSData *)spcData httpHeader:(NSDictionary<NSString *,NSString *> *)header {
    NSString *url = @"https://drm-license.doverunner.com/ri/licenseManager.do";
   
    NSHTTPURLResponse *response;
    __strong NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:header];
    [request setHTTPBody:spcData];
    
    NSData *rcvData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"Status Code : %d",  (int)response.statusCode);
    
    if( response.statusCode >= 400 || rcvData == nil || rcvData.length < 1 )
        return nil;
    
    return rcvData;
}
*/

@end
