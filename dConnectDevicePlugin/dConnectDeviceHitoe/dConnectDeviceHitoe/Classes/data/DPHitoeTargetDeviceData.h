//
//  DPHitoeDeviceData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPHitoeTargetDeviceData : NSObject<NSCopying>
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *manufacturerName;
@property (nonatomic, strong) NSString *modelNumber;
@property (nonatomic, strong) NSString *firmwareRevision;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *softwareRevision;
@property (nonatomic, strong) NSString *hardwareRevision;
@property (nonatomic, strong) NSString *partNumber;
@property (nonatomic, strong) NSString *protocolRevision;
@property (nonatomic, strong) NSString *systemId;
@property (nonatomic, assign) double batteryLevel;
- (DConnectMessage*)toDConnectMessage;
@end
