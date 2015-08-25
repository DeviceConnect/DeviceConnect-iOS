//
//  DPThetaParam.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/20.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
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
