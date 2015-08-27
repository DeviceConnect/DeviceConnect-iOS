//
//  DPThetaVector3D.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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


- (instancetype)initWithFloatArray:(NSMutableArray *)coords
{
    return [[DPThetaVector3D alloc] initWithX:[coords[0] floatValue]
                                            y:[coords[1] floatValue]
                                            z:[coords[2] floatValue]];
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




- (float)norm
{
    float v = 0;
    for (int i = 0; i < DPThetaVector3DSize; i++) {
        v += pow([_coords[i] floatValue], 2);
    }
    return (float) sqrt(v);
}


- (DPThetaVector3D*)normalize
{
    float norm = [self norm];
    if (norm == 0) {
        return self;
    }
    NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < _coords.count; i++) {
        coords[i] = [NSNumber numberWithFloat: (float) ([_coords[i] floatValue] / norm)];
    }
    
    return [[DPThetaVector3D alloc] initWithFloatArray:coords];
}


- (DPThetaVector3D*)addWithVector3D:(DPThetaVector3D *)vector
{
    return [[DPThetaVector3D alloc] initWithX:([self x] + [vector x])
                                            y:([self y] + [vector y])
                                            z:([self z] + [vector z]) ];
}

- (DPThetaVector3D*)multiplyByMultiplied:(float)multiplied
{
    return [[DPThetaVector3D alloc] initWithX:(float) (multiplied * [self x])
                                            y:(float) (multiplied * [self y])
                                            z:(float) (multiplied * [self z]) ];
    
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
