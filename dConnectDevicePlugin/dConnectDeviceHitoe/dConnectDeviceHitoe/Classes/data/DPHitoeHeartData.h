//
//  DPHitoeHeartData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPHitoeHeartData : NSObject

enum DPHitoeHeart {
    DPHitoeHeartRate,
    DPHitoeHeartRRI,
    DPHitoeHeartEnergyExpended,
    DPHitoeHeartECG
};

@property (nonatomic, assign) enum DPHitoeHeartData heartType;
@property (nonatomic, assign) float value;
@property (nonatomic,copy) NSString *mderFloat;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) int typeCode;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, assign) int unitCode;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, copy) NSString *timeStampString;
@end
