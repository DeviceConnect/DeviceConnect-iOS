//
//  DPThetaCamera.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaCamera.h"
#import "DPThetaCameraBuilder.h"

@implementation DPThetaCamera


- (instancetype)initWithFovDegree:(float)fovDegree
                         position:(DPThetaVector3D *)position
                   frontDirection:(DPThetaVector3D *)frontDirection
                   upperDirection:(DPThetaVector3D *)upperDirection
                   rightDirection:(DPThetaVector3D *)rightDirection
                         attitude:(DPThetaQuaternion *)attitude
{
    self = [super init];
    if (self) {
        _fovDegree = fovDegree;
        _position = position;
        _frontDirection = frontDirection;
        _upperDirection = upperDirection;
        _rightDirection = rightDirection;
        _attitude = attitude;
    }
    return self;
}

- (instancetype)init
{
    
    return [[DPThetaCamera alloc] initWithFovDegree:90
                                          position:[[DPThetaVector3D alloc] initWithX:0.0f y:0.0f z:0.0f]
                                    frontDirection:[[DPThetaVector3D alloc] initWithX:1.0f y:0.0f z:0.0f]
                                    upperDirection:[[DPThetaVector3D alloc] initWithX:0.0f y:1.0f z:0.0f]
                                    rightDirection:[[DPThetaVector3D alloc] initWithX:0.0f y:0.0f z:1.0f]
                                          attitude:[DPThetaQuaternion quaternionFromAxisAndAngle:
                                                        [[DPThetaVector3D alloc] initWithX:1.0f y:0.0f z:0.0f]
                                                                                          radian:0]];
}


- (NSArray*)getCameraForStereoForDistance:(float)distance
{
    DPThetaCameraBuilder *leftCamera = [[DPThetaCameraBuilder alloc] initWithCamera:self];
    [leftCamera slideHorizontalWithDelta:-1 * distance];
    DPThetaCameraBuilder *rightCamera = [[DPThetaCameraBuilder alloc] initWithCamera:self];
    [rightCamera slideHorizontalWithDelta:distance];
    
    return [NSArray arrayWithObjects:leftCamera, rightCamera, nil];
    
}

@end
