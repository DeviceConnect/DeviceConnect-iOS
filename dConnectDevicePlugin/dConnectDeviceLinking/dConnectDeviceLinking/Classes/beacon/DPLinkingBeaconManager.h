//
//  DPLinkingBeaconManager.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPLinkingBeacon.h"


@protocol DPLinkingBeaconEventDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon;
@end

@protocol DPLinkingBeaconConnectDelegate <NSObject>
@optional
- (void) didConnectedBeacon:(DPLinkingBeacon *)beacon;
- (void) didDisconnectedBeacon:(DPLinkingBeacon *)beacon;
@end

@protocol DPLinkingBeaconAtmosphericPressureDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon AtmosphericPressure:(DPLinkingAtmosphericPressureData *)atmosphericPressure;
@end

@protocol DPLinkingBeaconTemperatureDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon temperature:(DPLinkingTemperatureData *)temperature;
@end

@protocol DPLinkingBeaconHumidityDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon humidty:(DPLinkingHumidityData *)humidity;
@end

@protocol DPLinkingBeaconBatteryDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon battery:(DPLinkingBattryData *)battery;
@end

@protocol DPLinkingBeaconGattDataDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon gattData:(DPLinkingGattData *)gatt;
@end

@protocol DPLinkingBeaconRawDataDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon rawData:(DPLinkingRawData *)rawData;
@end

@protocol DPLinkingBeaconButtonIdDelegate <NSObject>
@optional
- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon ButtonId:(int)buttonId;
@end

@interface DPLinkingBeaconManager : NSObject
+ (DPLinkingBeaconManager *) sharedInstance;

- (DPLinkingBeacon *) findBeaconByExtraId:(long)extraId venderId:(long)vendorId;
- (DPLinkingBeacon *) findBeaconByBeaconId:(NSString *)beaconId;

- (NSArray *) getBeacons;
- (void) removeBeacon:(int)index;

- (void) startBeaconScan;
- (void) stopBeaconScan;
- (BOOL) isStartBeaconScan;

- (void) startBeaconScanWithTimeout:(float)timeout;

- (void) addBeaconEventDelegate:(id<DPLinkingBeaconEventDelegate>)delegate;
- (void) removeBeaconEventDelegate:(id<DPLinkingBeaconEventDelegate>)delegate;

- (void) addConnectDelegate:(id<DPLinkingBeaconConnectDelegate>)delegate;
- (void) removeConnectDelegate:(id<DPLinkingBeaconConnectDelegate>)delegate;

- (void) addAtmosphericPressureDelegate:(id<DPLinkingBeaconAtmosphericPressureDelegate>)delegate;
- (void) removeAtmosphericPressureDelegate:(id<DPLinkingBeaconAtmosphericPressureDelegate>)delegate;

- (void) addTemperatureDelegate:(id<DPLinkingBeaconTemperatureDelegate>)delegate;
- (void) removeTemperatureDelegate:(id<DPLinkingBeaconTemperatureDelegate>)delegte;

- (void) addHumidityDelegate:(id<DPLinkingBeaconHumidityDelegate>)delegate;
- (void) removeHumidityDelegate:(id<DPLinkingBeaconHumidityDelegate>)delegate;

- (void) addGattDataDelegate:(id<DPLinkingBeaconGattDataDelegate>)delegate;
- (void) removeGattDataDelegate:(id<DPLinkingBeaconGattDataDelegate>)delegate;

- (void) addBatteryDelegate:(id<DPLinkingBeaconBatteryDelegate>)delegate;
- (void) removeBatteryDelegate:(id<DPLinkingBeaconBatteryDelegate>)delegate;

- (void) addButtonIdDelegate:(id<DPLinkingBeaconButtonIdDelegate>)delegate;
- (void) removeButtonIdDelegate:(id<DPLinkingBeaconButtonIdDelegate>)delegate;

- (void) addRawDataDelegate:(id<DPLinkingBeaconRawDataDelegate>)delegate;
- (void) removeRawDataDelegate:(id<DPLinkingBeaconRawDataDelegate>)delegate;

@end
