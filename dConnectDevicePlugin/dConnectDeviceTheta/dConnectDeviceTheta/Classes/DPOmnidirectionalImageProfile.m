//
//  DPOmnidirectionalImageProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
