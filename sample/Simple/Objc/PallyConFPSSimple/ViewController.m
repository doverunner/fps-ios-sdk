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
#define PALLYCON_SITE_ID        @""
#define PALLYCON_SITE_KEY       @""
#define PALLYCON_TOKEN          @""
#define CONTENT_PATH            @""


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. initialize a PallyConFPS SDK.
    _fpsSDK = [[PallyConFPSSDK alloc] initWithSiteId:PALLYCON_SITE_ID siteKey:PALLYCON_SITE_KEY fpsLicenseDelegate:self error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    NSURL *contentUrl = [NSURL URLWithString:CONTENT_PATH];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:contentUrl options:nil];

    // 2. Set parameters required for FPS content playback.
    [_fpsSDK prepareWithUrlAsset:urlAsset token:PALLYCON_TOKEN licenseUrl:@"" appleCertUrl:@""];
    
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

- (void)fpsLicenseDidSuccessAcquiringWithContentId:(NSString * _Nonnull)contentId {
    NSLog(@"fpsLicenseDidSuccessAcquiringWithContentId (%@)", contentId);
}

- (void)fpsLicenseWithContentId:(NSString * _Nonnull)contentId didFailWithError:(NSError * _Nonnull)error {
    NSLog(@"fpsLicenseWithContentId. Error Message (%@)", error.localizedDescription);
}

/*
- (NSData *)contentKeyRequestWithKeyData:(NSData *)keyData requestData:(NSDictionary<NSString *,NSString *> *)requestData {
        
    NSString *url = @"https://license.pallycon.com/ri/licenseManager.do";
   
    NSHTTPURLResponse *response;
    __strong NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:requestData];
    [request setHTTPBody:keyData];
    
    NSData *rcvData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"Status Code : %d",  (int)response.statusCode);
    
    if( response.statusCode >= 400 || rcvData == nil || rcvData.length < 1 )
        return nil;
    
    return rcvData;
}
*/

@end
