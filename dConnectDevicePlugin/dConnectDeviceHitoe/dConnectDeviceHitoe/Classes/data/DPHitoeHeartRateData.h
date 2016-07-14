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

@interface DPHitoeHeartRateData : NSObject
@property (nonatomic, copy) DPHitoeTargetDeviceData *target;
@property (nonatomic, copy) DPHitoeHeartData *heartRate;
@property (nonatomic, copy) DPHitoeHeartData *rrinterval;
@property (nonatomic, copy) DPHitoeHeartData *energyExpended;
@property (nonatomic, copy) DPHitoeHeartData *ecg;
@end
