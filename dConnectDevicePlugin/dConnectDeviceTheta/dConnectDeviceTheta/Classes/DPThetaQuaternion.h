//
//  DPThetaQuaternion.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPThetaVector3D.h"

@interface DPThetaQuaternion : NSObject
@property (nonatomic) float real;
@property (nonatomic) DPThetaVector3D *imaginary;

- (instancetype)initWithReal:(float)real imaginary:(DPThetaVector3D*)imaginary;
- (instancetype)initWithQuaternion:(DPThetaQuaternion *)q;
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
+ (DPThetaQuaternion *)quaternionFromAxisAndAngle:(DPThetaVector3D *)normalizedAxis
                                           radian:(float)radian;
@end
