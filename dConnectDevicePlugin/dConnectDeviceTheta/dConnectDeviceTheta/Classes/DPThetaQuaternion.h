//
//  DPThetaQuaternion.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPThetaVector3D.h"

@interface DPThetaQuaternion : NSObject
@property (nonatomic) float real;
@property (nonatomic) DPThetaVector3D *imaginary;

- (instancetype)initWithReal:(float)real imaginary:(DPThetaVector3D*)imaginary;

- (DPThetaQuaternion *)conjugate;
- (DPThetaQuaternion *)multiplyWithQuaternion:(DPThetaQuaternion*)q;

+ (DPThetaQuaternion *)multiplyWithQuaternionArray:(NSMutableArray *)qArray;
+ (DPThetaVector3D *)rotateByPoint:(DPThetaVector3D *)point
                              axis:(DPThetaVector3D *)axis
                            radian:(float)radian;
+ (DPThetaVector3D *)rotateXYZByPoint:(DPThetaVector3D *)point
                              rotateX:(float)rotateX
                              rotateY:(float)rotateY
                              rotateZ:(float)rotateZ;
@end
