//
//  ViewController.m
//  PallyConFPSSimple
//
//  Created by PallyCon on 2018. 4. 5..
//  Copyright © 2018년 inka. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

// This is customer-specific information.
// you have to set customer information.
#define CERTIFICATE_URL     @"https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=????"
#define CONTENT_ID          @""
#define PALLYCON_TOKEN      @""
#define CONTENT_URL         @""

@protocol PallyConFPSLicenseDelegate;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. initialize a PallyConFPS SDK.
    _fpsSDK = [[PallyConFPSSDK alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    NSURL *contentUrl = [NSURL URLWithString:CONTENT_URL];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:contentUrl options:nil];

    // 2. Set parameters required for FPS content playback.
    PallyConDrmConfiguration* config = [[PallyConDrmConfiguration alloc] initWithAvURLAsset:urlAsset contentId:CONTENT_ID certificateUrl:CERTIFICATE_URL authData:PALLYCON_TOKEN delegate:self licenseUrl:nil licenseHttpHeader:nil licenseCookies:nil renewalInterval:0];
    [_fpsSDK prepareWithContent:config];
    
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

- (void)licenseWithResult:(PallyConResult *)result {
    NSLog(@"%@",result.contentId);
    if (result.isSuccess == false) {
        NSLog(@"%@", [result getPallyConErrorForObjC]);
    }
}

/*
- (NSData *)licenseCallbackWith:(NSData *)spcData httpHeader:(NSDictionary<NSString *,NSString *> *)header {
    NSString *url = @"https://license.pallycon.com/ri/licenseManager.do";
   
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
