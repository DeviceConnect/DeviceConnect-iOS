//
//  DPAllJoynSupportCheck.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPAllJoynServiceEntity.h"



@interface DPAllJoynSupportCheck : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (BOOL)isSupported:(AJNMessageArgument *)busObjectDescriptions;
+ (NSArray *)supportedProfileNamesWithProvider:(id<DConnectProfileProvider>)provider
                                       service:(DPAllJoynServiceEntity *)service;

@end
