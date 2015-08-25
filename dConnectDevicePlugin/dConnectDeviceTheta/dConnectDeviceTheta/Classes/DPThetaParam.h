//
//  DPThetaParam.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/20.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPThetaParam : NSObject

@property (nonatomic) double cameraX;
@property (nonatomic) double cameraY;
@property (nonatomic) double cameraZ;
@property (nonatomic) double cameraYaw;
@property (nonatomic) double cameraRoll;
@property (nonatomic) double cameraPitch;
@property (nonatomic) double cameraFOV;
@property (nonatomic) double sphereSize;
@property (nonatomic) int imageWidth;
@property (nonatomic) int imageHeight;
@property (nonatomic) BOOL stereoMode;
@property (nonatomic) BOOL vrMode;
@end
