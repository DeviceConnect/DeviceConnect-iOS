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
#import "DPHitoeDeviceData.h"
#import "DPHitoeConsts.h"


@protocol DPHitoeConnectionDelegate<NSObject>

-(void)connectWithDevice:(DPHitoeDevice*)device;
-(void)connectFailWithDevice:(DPHitoeDevice*)device;
-(void)disconnectWithDevice:(DPHitoeDevice*)device;
-(void)discoveryForDevices:(NSMutableArray*)devices;
-(void)deleteAtDevice:(DPHitoeDevice*)device;
@end


@interface DPHitoeManager : NSObject<HitoeSdkAPIDelegate, DataReceiveDelegate>

#pragma mark - Delegate object
@property (nonatomic, weak) id<DPHitoeConnectionDelegate> connectionDelegate;

@property (nonatomic, copy) void (^heartRateReceived)(DPHitoeDeviceData *device, DPHitoeHeartRateData *heartRate);
@property (nonatomic, copy) void (^ecgReceived)(DPHitoeDeviceData *device, DPHitoeHeartRateData *ecg);
@property (nonatomic, copy) void (^stressEstimationReceived)(DPHitoeDeviceData *device, DPHitoeStressEstimationData *stress);
@property (nonatomic, copy) void (^poseEstimationReceived)(DPHitoeDeviceData *device, DPHitoePoseEstimationData *pose);
@property (nonatomic, copy) void (^walkStateReceived)(DPHitoeDeviceData *device, DPHitoeWalkStateData *walk);

#pragma mark - store data
@property (nonatomic, copy) NSMutableArray *registeredDevices;
#pragma mark - Public method
- (void)start;
- (void)stop;
- (void)discovery;
- (void)connectForHitoe:(DPHitoeDevice *)device;
- (void)disconnectForHitoe:(DPHitoeDevice *)device;
- (void)deleteAtHitoe:(DPHitoeDevice *)device;
- (BOOL)containsConnectedHitoeDevice:(NSString *)serviceId;

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
