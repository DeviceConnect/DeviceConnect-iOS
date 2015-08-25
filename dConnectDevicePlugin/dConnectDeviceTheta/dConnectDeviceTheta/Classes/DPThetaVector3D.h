//
//  DPThetaVector3D.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPThetaVector3D : NSObject



- (instancetype)initWithX:(float)x y:(float)y z:(float)z;
- (instancetype)initWithVector3D:(DPThetaVector3D *)vector;
- (float)x;
- (float)y;
- (float)z;

- (float)length;

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
