//
//  DPSpheroProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroProfile.h"
#import <DConnectSDK/DConnectUtil.h>


/*
 Profileの名前
 */
NSString *const DPSpheroProfileName = @"sphero";

/*
 インタフェース: sphero
 */
NSString *const DPSpheroProfileInterfaceQuaternion = @"quaternion";
NSString *const DPSpheroProfileInterfaceLocator = @"locator";
NSString *const DPSpheroProfileInterfaceCollision = @"collision";


/*
 アトリビュート: sphero
 */

NSString *const DPSpheroProfileAttrOnQuaternion = @"onquaternion";
NSString *const DPSpheroProfileAttrOnLocator = @"onlocator";
NSString *const DPSpheroProfileAttrOnCollision = @"oncollision";

/*
 パラメータ: sphero
 */
NSString *const DPSpheroProfileParamQuaternion = @"quaternion";
NSString *const DPSpheroProfileParamQ0 = @"q0";
NSString *const DPSpheroProfileParamQ1 = @"q1";
NSString *const DPSpheroProfileParamQ2 = @"q2";
NSString *const DPSpheroProfileParamQ3 = @"q3";
NSString *const DPSpheroProfileParamInterval = @"interval";
NSString *const DPSpheroProfileParamFlag = @"flag";
NSString *const DPSpheroProfileParamNewX = @"newX";
NSString *const DPSpheroProfileParamNewY = @"newY";
NSString *const DPSpheroProfileParamNewCalibration = @"newCalibration";
NSString *const DPSpheroProfileParamLocator = @"locator";
NSString *const DPSpheroProfileParamPositionX = @"positionX";
NSString *const DPSpheroProfileParamPositionY = @"positionY";
NSString *const DPSpheroProfileParamVelocityX = @"velocityX";
NSString *const DPSpheroProfileParamVelocityY = @"velocityY";
NSString *const DPSpheroProfileParamXThreshold = @"xThreshold";
NSString *const DPSpheroProfileParamYThreshold = @"yThreshold";
NSString *const DPSpheroProfileParamXSpeedThreshold = @"xSpeedThreshold";
NSString *const DPSpheroProfileParamYSpeedThreshold = @"ySpeedThreshold";
NSString *const DPSpheroProfileParamDeadZone = @"deadZone";
NSString *const DPSpheroProfileParamCollision = @"collision";
NSString *const DPSpheroProfileParamImpactAcceleration = @"impactAcceleration";
NSString *const DPSpheroProfileParamX = @"x";
NSString *const DPSpheroProfileParamY = @"y";
NSString *const DPSpheroProfileParamZ = @"z";
NSString *const DPSpheroProfileParamImpactAxis = @"impactAxis";
NSString *const DPSpheroProfileParamImpactPower = @"impactPower";
NSString *const DPSpheroProfileParamImpactSpeed = @"impactSpeed";
NSString *const DPSpheroProfileParamImpactTimeStamp = @"impactTimeStamp";
NSString *const DPSpheroProfileParamImpactTimeStampString = @"impactTimeStampString";


@implementation DPSpheroProfile

/*
 このプロファイルの名前を返す。
 */
- (NSString *) profileName {
    return DPSpheroProfileName;
}

@end
