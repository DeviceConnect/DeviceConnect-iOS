//
//  DPThetaVector3D.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPThetaVector3D : NSObject



- (instancetype)initWithX:(float)x y:(float)y z:(float)z;
- (instancetype)initWithVector3D:(DPThetaVector3D *)vector;
- (float)x;
- (float)y;
- (float)z;


- (float)norm;
- (DPThetaVector3D*)normalize;


- (DPThetaVector3D*)addWithVector3D:(DPThetaVector3D *)vector;
- (DPThetaVector3D*)multiplyByMultiplied:(float)multiplied;

+ (DPThetaVector3D*)multiplyByMultiplied:(float)multiplied
                                toVector:(DPThetaVector3D *)toVector;

+ (DPThetaVector3D*)addWithVector3DArrays:(NSMutableArray *)vectors;


+ (float)innerProductWithVector3D:(DPThetaVector3D *)vector
                                    toVector:(DPThetaVector3D *)toVector;

+ (DPThetaVector3D*)outerProductWithVector3D:(DPThetaVector3D *)vector
                                    toVector:(DPThetaVector3D *)toVector;



@end
