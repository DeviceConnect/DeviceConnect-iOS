//
//  DPHitoeManager.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <hitoeAPI/hitoeAPI.h>
#import "DPHitoeDevice.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeStressEstimationData.h"
#import "DPHitoePoseEstimationData.h"
#import "DPHitoeWalkStateData.h"
#import "DPHitoeAccelerationData.h"
#import "DPHitoeHeartData.h"
#import "DPHitoeTargetDeviceData.h"
#import "DPHitoeConsts.h"
#import "DPHitoeHeartData.h"





@interface DPHitoeManager : NSObject<HitoeSdkAPIDelegate, DataReceiveDelegate>
#pragma mark - Notification key
extern NSString *const DPHitoeConnectDeviceNotification;
extern NSString *const DPHitoeConnectFailedDeviceNotification;
extern NSString *const DPHitoeDisconnectNotification;
extern NSString *const DPHitoeDiscoveryDeviceNotification;
extern NSString *const DPHitoeDeleteDeviceNotification;

#pragma mark - Notification object key

extern NSString *const DPHitoeConnectDeviceObject;
extern NSString *const DPHitoeConnectFailedDeviceObject;
extern NSString *const DPHitoeDisconnectObject;
extern NSString *const DPHitoeDiscoveryDeviceObject;
extern NSString *const DPHitoeDeleteDevicObject;

#pragma mark - Delegate object
@property (nonatomic, copy) void (^heartRateReceived)(DPHitoeDevice *device, DPHitoeHeartRateData *heartRate);
@property (nonatomic, copy) void (^ecgReceived)(DPHitoeDevice *device, DPHitoeHeartRateData *ecg);
@property (nonatomic, copy) void (^stressEstimationReceived)(DPHitoeDevice *device, DPHitoeStressEstimationData *stress);
@property (nonatomic, copy) void (^poseEstimationReceived)(DPHitoeDevice *device, DPHitoePoseEstimationData *pose);
@property (nonatomic, copy) void (^walkStateReceived)(DPHitoeDevice *device, DPHitoeWalkStateData *walk);
@property (nonatomic, copy) void (^accelReceived)(DPHitoeDevice *device, DPHitoeAccelerationData *walk);

#pragma mark - store data
@property (nonatomic, copy) NSMutableArray *registeredDevices;
#pragma mark - Public method
- (void)discovery;

- (void)readHitoeData;
- (void)connectForHitoe:(DPHitoeDevice *)device;
- (void)disconnectForHitoe:(DPHitoeDevice *)device;
- (void)deleteAtHitoe:(DPHitoeDevice *)device;
- (BOOL)containsConnectedHitoeDevice:(NSString *)serviceId;

- (void)startRetryTimer;
- (void)stopRetryTimer;

- (DPHitoeDevice *)getHitoeDeviceForServiceId:(NSString *)serviceId;
- (DPHitoeHeartRateData *)getHeartRateDataForServiceId:(NSString *)serviceId;
- (DPHitoeHeartRateData *)getECGDataForServiceId:(NSString *)serviceId;
- (DPHitoeStressEstimationData *)getStressEstimationDataForServiceId:(NSString *)serviceId;
- (DPHitoePoseEstimationData *)getPoseEstimationDataForServiceId:(NSString *)serviceId;
- (DPHitoeWalkStateData *)getWalkStateDataForServiceId:(NSString *)serviceId;
- (DPHitoeAccelerationData *)getAccelerationDataForServiceId:(NSString *)serviceId;


#pragma mark - Static method
+ (DPHitoeManager *)sharedInstance;
@end
