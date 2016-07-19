//
//  DPLinkingBeacon.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <LinkingLibrary/LinkingLibrary.h>

#import "DPLinkingAtmosphericPressureData.h"
#import "DPLinkingBattryData.h"
#import "DPLinkingGattData.h"
#import "DPLinkingHumidityData.h"
#import "DPLinkingRawData.h"
#import "DPLinkingTemperatureData.h"

@interface DPLinkingBeacon : NSObject

@property (nonatomic) long extraId;
@property (nonatomic) long vendorId;
@property (nonatomic) long version;

@property (nonatomic) BOOL online;

@property (nonatomic) NSString *beaconId;
@property (nonatomic) NSString *displayName;

@property (nonatomic) DPLinkingAtmosphericPressureData *atmosphericPressureData;
@property (nonatomic) DPLinkingBattryData *batteryData;
@property (nonatomic) DPLinkingGattData *gattData;
@property (nonatomic) DPLinkingHumidityData *humidityData;
@property (nonatomic) DPLinkingRawData *rawData;
@property (nonatomic) DPLinkingTemperatureData *temperatureData;

+ (NSString *) createDisplayName:(long)extraId;
+ (NSString *) createIdFromVendorId:(long)vendorId extraId:(long)extraId;

@end
