//
//  DPHitoeRawDataParseUtil.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <Foundation/Foundation.h>
#import <DCMDevicePluginSDK/DCMPoseEstimationProfile.h>
#import <DCMDevicePluginSDK/DCMWalkStateProfile.h>
#import "DPHitoeConsts.h"
#import "DPHitoeHeartData.h"
#import "DPHitoeTargetDeviceData.h"
#import "DPHitoeDevice.h"
#import "DPHitoeAccelerationData.h"
#import "DPHitoeStressEstimationData.h"
#import "DPHitoePoseEstimationData.h"
#import "DPHitoeWalkStateData.h"

@interface DPHitoeRawDataParseUtil : NSObject
+ (DPHitoeHeartData *)parseHeartRateWithRaw:(NSString*)raw;

+ (DPHitoeHeartData *)parseRRIWithRaw:(NSString*)raw;
+ (DPHitoeHeartData * )parseEnergyExpendedWithRaw:(NSString*)raw;

+ (DPHitoeTargetDeviceData *)parseDeviceDataWithDevice:(DPHitoeDevice *)device
                                          batteryLevel:(float)batteryLevel;

+ (void)parseAccelerationData:(DPHitoeAccelerationData *)data
                          raw:(NSString *)raw;

+ (DPHitoeHeartData*)parseECGWithRaw:(NSString *)raw;

+ (DPHitoeStressEstimationData*)parseStressEstimationWithRaw:(NSString*)raw;

+ (DPHitoePoseEstimationData *)parsePoseEstimationWithRaw:(NSString*)raw;
+ (DPHitoeWalkStateData*)parseWalkStateWithData:(DPHitoeWalkStateData*)data
                                            raw:(NSString*)raw;
+ (DPHitoeWalkStateData*)parseWalkStateForBalanceWithData:(DPHitoeWalkStateData*)data
                                                      raw:(NSString*)raw;
@end
