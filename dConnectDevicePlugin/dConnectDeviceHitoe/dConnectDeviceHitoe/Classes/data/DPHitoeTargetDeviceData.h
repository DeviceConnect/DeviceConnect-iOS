//
//  DPHitoeDeviceData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHitoeTargetDeviceData : NSObject
@property (nonatomic, copy) NSString *productName;
@property (nonatomic, copy) NSString *manufacturerName;
@property (nonatomic, copy) NSString *modelNumber;
@property (nonatomic, copy) NSString *firmwareRevision;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *softwareRevision;
@property (nonatomic, copy) NSString *hardwareRevision;
@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, copy) NSString *protocolRevision;
@property (nonatomic, copy) NSString *systemId;
@property (nonatomic, assign) float batteryLevel;
@end
