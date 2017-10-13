//
//  DPHostMediaPlayerFactory.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHostMediaPlayer.h"
#import "DPHostMediaContext.h"
@interface DPHostMediaPlayerFactory : NSObject
+ (DPHostMediaPlayer*)createPlayerWithMediaId:(NSString*)mediaId
                                       plugin:(DPHostDevicePlugin*)plugin
                                        error:(NSError**)error;

+ (NSArray*)searchMediaWithQuery:(NSString*)query
                        mimeType:(NSString*)mimeType
                           order:(NSString*)order
                          offset:(NSNumber*)offset
                           limit:(NSNumber*)limit
                           error:(NSError**)error;
@end
