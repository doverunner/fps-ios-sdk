//
//  OpensslObject.h
//  PallyConFPSSDK
//
//  Created by PallyCon on 2017. 8. 17..
//  Copyright © 2017년 INKA Entworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpensslObject : NSObject

-(NSData*)aesEncrypt:(NSString*)key iv:(NSString*)iv message:(NSString*)message;
-(NSData*)aesDecrypt:(NSString*)key iv:(NSString*)iv data:(NSData*)data;

@end
