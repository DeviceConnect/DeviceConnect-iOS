//
//  DPThetaCameraBuilder.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import "DPThetaROI.h"

@interface DPThetaCameraBuilder : NSObject
@property (nonatomic) float fovDegree;
@property (nonatomic) DPThetaVector3D *position;
@property (nonatomic) DPThetaVector3D *frontDirection;
@property (nonatomic) DPThetaVector3D *upperDirection;
@property (nonatomic) DPThetaVector3D *rightDirection;
@property (nonatomic) DPThetaQuaternion *attitude;


- (instancetype)initWithCamera:(DPThetaCamera*)camera;


- (DPThetaCamera *)create;
- (void)slideHorizontalWithDelta:(float)delta;
- (void)rotateByEulerAngleForRoll:(float)roll yaw:(float)yaw pitch:(float)pitch;
- (void)rotateForQuaternion:(DPThetaQuaternion *)q;


@end
