//
//  DPHitoeAccelerationData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPHitoeAccelerationData : NSObject<NSCopying>

@property (nonatomic, assign) double accelX;
@property (nonatomic, assign) double accelY;
@property (nonatomic, assign) double accelZ;
@property (nonatomic, assign) long interval;
@end
