//
//  DPThetaParam.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaParam.h"

@implementation DPThetaParam

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cameraFOV = 90;
        _sphereSize = 1.0;
        _imageWidth = 320;
        _imageHeight = 504;
    }
    return self;
}
@end
