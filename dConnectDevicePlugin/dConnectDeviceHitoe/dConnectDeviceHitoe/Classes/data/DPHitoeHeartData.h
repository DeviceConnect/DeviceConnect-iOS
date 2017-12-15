//
//  DPHitoeHeartData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
@interface DPHitoeHeartData : NSObject<NSCopying>

typedef enum DPHitoeHeart : NSUInteger
{
    DPHitoeHeartRate = 0,
    DPHitoeHeartRRI,
    DPHitoeHeartEnergyExpended,
    DPHitoeHeartECG
} DPHitoeHeart;

@property (nonatomic, assign) enum DPHitoeHeart heartType;
@property (nonatomic, assign) float value;
@property (nonatomic, strong) NSString *mderFloat;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) int typeCode;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, assign) int unitCode;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, strong) NSString *timeStampString;

- (DConnectMessage*)toDConnectMessage;

@end
