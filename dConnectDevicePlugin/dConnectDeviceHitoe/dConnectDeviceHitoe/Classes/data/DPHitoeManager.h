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
#import "DPHitoeHeartData.h"
#import "DPHitoeDeviceData.h"

@protocol DPHitoeConnectionDelegate<NSObject>

-(void)connectWithDevice:(DPHitoeDevice*)device;
-(void)connectFailWithDevice:(DPHitoeDevice*)device;
-(void)discoveryForDevices:(NSArray*)devices;
-(void)deleteAtDevice:(DPHitoeDevice*)device;
@end


@interface DPHitoeManager : NSObject<HitoeSdkAPIDelegate, DataReceiveDelegate>

@property (nonatomic, copy) NSMutableArray *registeredDevices;
#pragma mark - Delegate object
@property (nonatomic, weak) id<DPHitoeConnectionDelegate> connectionDelegate;

@property (nonatomic, copy) void (^heartRateReceived)(DPHitoeDeviceData *device, DPHitoeHeartRateData *heartRate);
@property (nonatomic, copy) void (^ecgReceived)(DPHitoeDeviceData *device, DPHitoeHeartRateData *ecg);
@property (nonatomic, copy) void (^stressEstimationReceived)(DPHitoeDeviceData *device, DPHitoeStressEstimationData *stress);
@property (nonatomic, copy) void (^poseEstimationReceived)(DPHitoeDeviceData *device, DPHitoePoseEstimationData *pose);
@property (nonatomic, copy) void (^walkStateReceived)(DPHitoeDeviceData *device, DPHitoeWalkStateData *walk);


#pragma mark - Public method

#pragma mark - Static method
+ (DPHitoeManager *)sharedInstance;
@end
