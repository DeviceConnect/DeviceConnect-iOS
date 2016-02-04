//
//  DPThetaQuaternion.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaQuaternion.h"


@implementation DPThetaQuaternion

- (instancetype)initWithReal:(float)real imaginary:(DPThetaVector3D*)imaginary
{
    self = [super init];
    if (self) {
        _real = real;
        _imaginary = imaginary;
    }
    return self;
}

- (instancetype)initWithQuaternion:(DPThetaQuaternion *)q
{
    return [[DPThetaQuaternion alloc] initWithReal:q.real imaginary:q.imaginary];
}

- (DPThetaQuaternion *)conjugate
{
    return [[DPThetaQuaternion alloc] initWithReal:[self real] imaginary:[[self imaginary] multiplyByMultiplied:-1.0f]];
}

- (DPThetaQuaternion *)multiplyWithQuaternion:(DPThetaQuaternion*)q
{
    DPThetaQuaternion *thisQuaternion = self;
    float real = q.real * thisQuaternion.real
                            - [DPThetaVector3D innerProductWithVector3D:q.imaginary
                                                               toVector:thisQuaternion.imaginary];
    
    NSMutableArray *vectors = [NSMutableArray arrayWithObjects:[[q imaginary] multiplyByMultiplied:[thisQuaternion real]],
                               [[thisQuaternion imaginary] multiplyByMultiplied:[q real]],
                               [DPThetaVector3D outerProductWithVector3D:[q imaginary] toVector:[thisQuaternion imaginary]],
                               nil];
    DPThetaVector3D *imaginary = [DPThetaVector3D addWithVector3DArrays:vectors];
    return [[DPThetaQuaternion alloc] initWithReal:real imaginary:imaginary];
    
}

+ (DPThetaQuaternion *)multiplyWithQuaternionArray:(NSMutableArray *)qArray
{
    DPThetaQuaternion *v = qArray[qArray.count - 1];
    for (int i = (int) qArray.count - 2; i >= 0; i--) {
        v = [v multiplyWithQuaternion:(DPThetaQuaternion *) qArray[i]];
    }
    return v;
    
}


- (DPThetaVector3D *)rotateByTarget:(DPThetaVector3D *)target
{
    DPThetaQuaternion *p = [[DPThetaQuaternion alloc] initWithReal:0 imaginary:target];
    DPThetaQuaternion *q = self;
    DPThetaQuaternion *r = [self conjugate];
    return [[[r multiplyWithQuaternion:p] multiplyWithQuaternion:q] imaginary];
}

+ (DPThetaVector3D *)rotateByPoint:(DPThetaVector3D *)point
                              axis:(DPThetaVector3D *)axis
                            radian:(float)radian
{
    DPThetaQuaternion *q = [self quaternionFromAxisAndAngle:[axis normalize] radian:radian];
    return [q rotateByTarget:point];
}

+ (DPThetaVector3D *)rotateXYZByPoint:(DPThetaVector3D *)point
                              rotateX:(float)rotateX
                              rotateY:(float)rotateY
                              rotateZ:(float)rotateZ
{
    DPThetaVector3D *axisX = [[DPThetaVector3D alloc] initWithX:1 y:0 z:0];
    DPThetaVector3D *axisY = [[DPThetaVector3D alloc] initWithX:0 y:1 z:0];
    DPThetaVector3D *axisZ = [[DPThetaVector3D alloc] initWithX:0 y:0 z:1];
    
    DPThetaVector3D *result = point;
    result = [DPThetaQuaternion rotateByPoint:result axis:axisX radian:rotateX];
    result = [DPThetaQuaternion rotateByPoint:result axis:axisY radian:rotateY];
    result = [DPThetaQuaternion rotateByPoint:result axis:axisZ radian:rotateZ];
    
    return result;
}

+ (DPThetaQuaternion *)quaternionFromAxisAndAngle:(DPThetaVector3D *)normalizedAxis
                                           radian:(float)radian
{
    float c = (float) cos(radian / 2.0f);
    float s = (float) sin(radian / 2.0f);
    return [[DPThetaQuaternion alloc] initWithReal:c imaginary:[normalizedAxis multiplyByMultiplied:s]];
}

@end
