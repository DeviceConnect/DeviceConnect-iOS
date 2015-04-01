//
//  Utils.h
//  dConnectSDKSample
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface Utils : NSObject

+ (void) authorizeOrRefreshTokenWithForceRefresh:(BOOL)force
                                         success:(DConnectAuthorizationSuccessBlock)success
                                           error:(DConnectAuthorizationFailBlock)error;

+ (void) authorizeWithCompletion:(DConnectAuthorizationSuccessBlock)success
                           error:(DConnectAuthorizationFailBlock)error;

+ (void) refreshTokenWithCompletion:(DConnectAuthorizationSuccessBlock)success
                              error:(DConnectAuthorizationFailBlock)error;

@end
