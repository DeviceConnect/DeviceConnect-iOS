//
//  DPThetaCamera.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import "DPThetaVector3D.h"
#import "DPThetaQuaternion.h"
@interface DPThetaCamera : NSObject

@property (nonatomic) float fovDegree;
@property (nonatomic) DPThetaVector3D *position;
@property (nonatomic) DPThetaVector3D *frontDirection;
@property (nonatomic) DPThetaVector3D *upperDirection;
@property (nonatomic) DPThetaVector3D *rightDirection;
@property (nonatomic) DPThetaQuaternion *attitude;


- (instancetype)initWithFovDegree:(float)fovDegree
                         position:(DPThetaVector3D *)position
                   frontDirection:(DPThetaVector3D *)frontDirection
                   upperDirection:(DPThetaVector3D *)upperDirection
                   rightDirection:(DPThetaVector3D *)rightDirection
                         attitude:(DPThetaQuaternion *)attitude;
- (NSArray*)getCameraForStereoForDistance:(float)distance;

@end
