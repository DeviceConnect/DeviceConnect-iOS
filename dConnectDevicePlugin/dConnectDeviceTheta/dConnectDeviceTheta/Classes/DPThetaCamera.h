//
//  DPThetaCamera.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPThetaVector3D.h"
@interface DPThetaCamera : NSObject

@property (nonatomic) float fovDegree;
@property (nonatomic) DPThetaVector3D *position;
@property (nonatomic) DPThetaVector3D *frontDirection;
@property (nonatomic) DPThetaVector3D *upperDirection;
@property (nonatomic) DPThetaVector3D *rightDirection;


- (instancetype)initWithFovDegree:(float)fovDegree
                         position:(DPThetaVector3D *)position
                   frontDirection:(DPThetaVector3D *)frontDirection
                   upperDirection:(DPThetaVector3D *)upperDirection
                   rightDirection:(DPThetaVector3D *)rightDirection;
- (NSArray*)getCameraForStereoForDistance:(float)distance;

@end
