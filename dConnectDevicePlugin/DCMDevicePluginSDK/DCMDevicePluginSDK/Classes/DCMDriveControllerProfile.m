//
//  DCMDriveControllerProfileName.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMDriveControllerProfile.h"
#import <DConnectSDK/DConnectUtil.h>

NSString *const DCMDriveControllerProfileName = @"driveController";

NSString *const DCMDriveControllerProfileAttrMove = @"move";
NSString *const DCMDriveControllerProfileAttrStop = @"stop";
NSString *const DCMDriveControllerProfileAttrRotate = @"rotate";
NSString *const DCMDriveControllerProfileParamAngle = @"angle";
NSString *const DCMDriveControllerProfileParamSpeed = @"speed";

@implementation DCMDriveControllerProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMDriveControllerProfileName;
}

@end
