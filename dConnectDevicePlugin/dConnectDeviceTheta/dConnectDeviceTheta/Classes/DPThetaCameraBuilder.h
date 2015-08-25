//
//  DPThetaCameraBuilder.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPThetaCamera.h"
#import "DPThetaVector3D.h"
#import "DPThetaQuaternion.h"

@interface DPThetaCameraBuilder : NSObject
@property (nonatomic) float fovDegree;
@property (nonatomic) DPThetaVector3D *position;
@property (nonatomic) DPThetaVector3D *frontDirection;
@property (nonatomic) DPThetaVector3D *upperDirection;
@property (nonatomic) DPThetaVector3D *rightDirection;


- (instancetype)initWithCamera:(DPThetaCamera*)camera;


- (DPThetaCamera *)create;
- (void)slideHorizontalWithDelta:(float)delta;
- (void)rotateByEulerAngleForRoll:(float)roll yaw:(float)yaw pitch:(float)pitch;
- (void)rotateForQuaternion:(DPThetaQuaternion *)q;


@end
