//
//  DPAllJoynColorUtility.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>


@class AJNMessageArgument;
@class DPAllJoynServiceEntity;


@interface DPAllJoynColorUtility : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (NSDictionary *)HSBFromRGB:(NSString *)rgb;

@end
