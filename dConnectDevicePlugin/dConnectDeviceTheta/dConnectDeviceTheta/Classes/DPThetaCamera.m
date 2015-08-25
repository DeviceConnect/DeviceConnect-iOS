//
//  DPThetaCamera.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPThetaCamera.h"

#import "DPThetaCameraBuilder.h"

@implementation DPThetaCamera


- (instancetype)initWithFovDegree:(float)fovDegree
                         position:(DPThetaVector3D *)position
                   frontDirection:(DPThetaVector3D *)frontDirection
                   upperDirection:(DPThetaVector3D *)upperDirection
                   rightDirection:(DPThetaVector3D *)rightDirection
{
    self = [super init];
    if (self) {
        _fovDegree = fovDegree;
        _position = position;
        _frontDirection = frontDirection;
        _upperDirection = upperDirection;
        _rightDirection = rightDirection;
    }
    return self;
}

- (instancetype)init
{
    
    return [[DPThetaCamera alloc] initWithFovDegree:90
                                          position:[[DPThetaVector3D alloc] initWithX:0.0f y:0.0f z:0.0f]
                                    frontDirection:[[DPThetaVector3D alloc] initWithX:1.0f y:0.0f z:0.0f]
                                    upperDirection:[[DPThetaVector3D alloc] initWithX:0.0f y:1.0f z:0.0f]
                                    rightDirection:[[DPThetaVector3D alloc] initWithX:0.0f y:0.0f z:1.0f]];
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
