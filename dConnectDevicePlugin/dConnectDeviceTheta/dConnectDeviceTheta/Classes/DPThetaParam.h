//
//  DPThetaParam.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPThetaParam : NSObject

@property (nonatomic) double cameraX;
@property (nonatomic) double cameraY;
@property (nonatomic) double cameraZ;
@property (nonatomic) double cameraYaw;
@property (nonatomic) double cameraRoll;
@property (nonatomic) double cameraPitch;
@property (nonatomic) double cameraFOV;
@property (nonatomic) int sphereSize;
@property (nonatomic) int imageWidth;
@property (nonatomic) int imageHeight;
@property (nonatomic) BOOL stereoMode;
@property (nonatomic) BOOL vrMode;
@end
