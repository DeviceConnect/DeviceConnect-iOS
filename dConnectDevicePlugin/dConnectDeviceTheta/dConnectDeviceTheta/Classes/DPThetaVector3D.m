//
//  DPThetaVector3D.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/19.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPThetaVector3D.h"



static int const DPThetaVector3DSize = 3;

@interface DPThetaVector3D()
@property (nonatomic) NSMutableArray *coords;
@end
@implementation DPThetaVector3D



- (instancetype)initWithX:(float)x y:(float)y z:(float)z
{
    self = [super init];
    if (self) {
        _coords = [[NSMutableArray alloc] initWithCapacity:3];
        _coords[0] = [NSNumber numberWithFloat:x];
        _coords[1] = [NSNumber numberWithFloat:y];
        _coords[2] = [NSNumber numberWithFloat:z];
    }
    return self;
}

- (instancetype)initWithVector3D:(DPThetaVector3D *)vector
{
    return [[DPThetaVector3D alloc] initWithX:[vector x]
                                            y:[vector y]
                                            z:[vector z]];
}


- (float)x
{
    return [_coords[0] floatValue];
}
- (float)y
{
    return  [_coords[1] floatValue];
}
- (float)z
{
    return  [_coords[2] floatValue];
}

- (float)length
{
    float v = 0;
    for (int i = 0; i < DPThetaVector3DSize; i++) {
        v += pow([_coords[i] floatValue], 2);
    }
    return (float) sqrt(v);
}

- (DPThetaVector3D*)addWithVector3D:(DPThetaVector3D *)vector
{
    return [[DPThetaVector3D alloc] initWithX:([self x] + [vector x])
                                            y:([self y] + [vector y])
                                            z:([self z] + [vector z]) ];
}

- (DPThetaVector3D*)multiplyByMultiplied:(float)multiplied
{
    return [[DPThetaVector3D alloc] initWithX:(multiplied * [self x])
                                            y:(multiplied * [self y])
                                            z:(multiplied * [self z]) ];
    
}

+ (DPThetaVector3D*)multiplyByMultiplied:(float)multiplied
                                toVector:(DPThetaVector3D *)toVector
{
    return [toVector multiplyByMultiplied:multiplied];
}


+ (DPThetaVector3D*)addWithVector3DArrays:(NSMutableArray *)vectors
{
    DPThetaVector3D *v = [[DPThetaVector3D alloc] initWithX:0 y:0 z:0];
    for (int i = 0; i < vectors.count; i++) {
        v = [v addWithVector3D:vectors[i]];
    }
    return v;
}

+ (float)innerProductWithVector3D:(DPThetaVector3D *)vector
                                    toVector:(DPThetaVector3D *)toVector
{
    float v = 0;
    for (int i = 0; i < DPThetaVector3DSize; i++) {
        v += [vector.coords[i] floatValue] * [toVector.coords[i] floatValue];
    }
    return v;
}

+ (DPThetaVector3D*)outerProductWithVector3D:(DPThetaVector3D *)vector
                                    toVector:(DPThetaVector3D *)toVector
{
    float x = [vector y] * [toVector z] - [vector z] * [toVector y];
    float y = [vector z] * [toVector x] - [vector x] * [toVector z];
    float z = [vector x] * [toVector y] - [vector y] * [toVector x];
    return [[DPThetaVector3D alloc] initWithX:x y:y z:z];
}


@end
