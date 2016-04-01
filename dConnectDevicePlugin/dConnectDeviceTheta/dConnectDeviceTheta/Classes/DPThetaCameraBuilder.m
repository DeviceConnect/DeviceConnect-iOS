//
//  DPThetaCameraBuilder.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaCameraBuilder.h"

@implementation DPThetaCameraBuilder


- (instancetype)initWithCamera:(DPThetaCamera*)camera
{
    self = [super init];
    if (self) {
        _fovDegree = camera.fovDegree;
        _position = [[DPThetaVector3D alloc] initWithVector3D:camera.position];
        _frontDirection = [[DPThetaVector3D alloc] initWithVector3D:camera.frontDirection];
        _upperDirection = [[DPThetaVector3D alloc] initWithVector3D:camera.upperDirection];
        _rightDirection = [[DPThetaVector3D alloc] initWithVector3D:camera.rightDirection];
        if (camera.attitude) {
            _attitude = [[DPThetaQuaternion alloc] initWithQuaternion:camera.attitude];
        }
    }
    return self;
}

- (instancetype)init
{
    return [[DPThetaCameraBuilder alloc] initWithCamera:[[DPThetaCamera alloc] init]];
}

- (DPThetaCamera *)create
{
    return [[DPThetaCamera alloc] initWithFovDegree:_fovDegree
                                           position:_position
                                     frontDirection:_frontDirection
                                     upperDirection:_upperDirection
                                     rightDirection:_rightDirection
                                           attitude:_attitude];
}

- (void)slideHorizontalWithDelta:(float)delta
{
    _position = [[DPThetaVector3D alloc] initWithX:(delta * [_rightDirection x] + [_position x])
                                                 y:(delta * [_rightDirection y] + [_position y])
                                                 z:(delta * [_rightDirection z] + [_position z])];
}

- (void)rotateByEulerAngleForRoll:(float)roll yaw:(float)yaw pitch:(float)pitch
{
    DPThetaVector3D *lastFrontDirection = _frontDirection;
    float radianPerDegree = (float) (M_PI / 180.0f);
    
    float lat = (90.0f - pitch) * radianPerDegree;
    float lng = yaw * radianPerDegree;
    float x = (float)(sin(lat) * cos(lng));
    float y = (float)(cos(lat));
    float z = (float)(sin(lat) * sin(lng));
    _frontDirection = [[DPThetaVector3D alloc] initWithX:x y:y z:z];
    
    float dx = [_frontDirection x] - [lastFrontDirection x];
    float dy = [_frontDirection y] - [lastFrontDirection y];
    float dz = [_frontDirection z] - [lastFrontDirection z];
    
    float theta = roll * radianPerDegree;
    DPThetaQuaternion *q = [[DPThetaQuaternion alloc] initWithReal:(float) cos(theta / 2.0f)
                                                         imaginary:[_frontDirection multiplyByMultiplied:(float) sin(theta / 2.0)]];
    _upperDirection = [self rotateWithVector3D:_upperDirection quaternion:q];
    _rightDirection = [_rightDirection addWithVector3D:[[DPThetaVector3D alloc] initWithX:dx y:dy z:dz]];
    _rightDirection = [self rotateWithVector3D:_rightDirection quaternion:q];
    
}

- (void)rotateForQuaternion:(DPThetaQuaternion *)q
{
    _frontDirection = [self rotateWithVector3D:[[DPThetaVector3D alloc] initWithX:1 y:0 z:0] quaternion:q];
//    _upperDirection = [self rotateWithVector3D:[[DPThetaVector3D alloc] initWithX:0 y:1 z:0] quaternion:q];
    _rightDirection = [self rotateWithVector3D:[[DPThetaVector3D alloc] initWithX:0 y:0 z:1] quaternion:q];
}

- (DPThetaVector3D *)rotateWithVector3D:(DPThetaVector3D *)vector
                             quaternion:(DPThetaQuaternion *)quaternion
{
    DPThetaQuaternion *p = [[DPThetaQuaternion alloc] initWithReal:0 imaginary:vector];
    DPThetaQuaternion *r = [quaternion conjugate];
    DPThetaQuaternion *qpr = [[r multiplyWithQuaternion:p] multiplyWithQuaternion:quaternion];
    return [qpr imaginary];
}


@end
