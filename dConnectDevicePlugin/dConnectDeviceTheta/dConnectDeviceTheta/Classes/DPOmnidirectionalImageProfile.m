//
//  DPOmnidirectionalImageProfile.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/23.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPOmnidirectionalImageProfile.h"

NSString *const DPOmnidirectionalImageProfileName = @"omnidirectionalImage";


NSString *const DPOmnidirectionalImageProfileInterfaceROI = @"roi";
NSString *const DPOmnidirectionalImageProfileAttrROI = @"roi";
NSString *const DPOmnidirectionalImageProfileAttrSettings = @"settings";
NSString *const DPOmnidirectionalImageProfileParamSource = @"source";
NSString *const DPOmnidirectionalImageProfileParamX = @"x";
NSString *const DPOmnidirectionalImageProfileParamY = @"y";
NSString *const DPOmnidirectionalImageProfileParamZ = @"z";
NSString *const DPOmnidirectionalImageProfileParamRoll = @"roll";
NSString *const DPOmnidirectionalImageProfileParamPitch = @"pitch";
NSString *const DPOmnidirectionalImageProfileParamYaw = @"yaw";
NSString *const DPOmnidirectionalImageProfileParamFOV = @"fov";
NSString *const DPOmnidirectionalImageProfileParamSphereSize = @"sphereSize";
NSString *const DPOmnidirectionalImageProfileParamWidth = @"width";
NSString *const DPOmnidirectionalImageProfileParamHeight = @"height";
NSString *const DPOmnidirectionalImageProfileParamStereo = @"stereo";
NSString *const DPOmnidirectionalImageProfileParamVR = @"vr";
NSString *const DPOmnidirectionalImageProfileParamURI = @"uri";




@implementation DPOmnidirectionalImageProfile

- (NSString *) profileName {
    return DPOmnidirectionalImageProfileName;
}

@end
