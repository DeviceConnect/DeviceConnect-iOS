//
//  DPHitoeHeartRateData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import "DPHitoeTargetDeviceData.h"
#import "DPHitoeHeartData.h"

@interface DPHitoeHeartRateData : NSObject<NSCopying>
@property (nonatomic, strong) DPHitoeTargetDeviceData *target;
@property (nonatomic, strong) DPHitoeHeartData *heartRate;
@property (nonatomic, strong) DPHitoeHeartData *rrinterval;
@property (nonatomic, strong) DPHitoeHeartData *energyExpended;
@property (nonatomic, strong) DPHitoeHeartData *ecg;
@end
