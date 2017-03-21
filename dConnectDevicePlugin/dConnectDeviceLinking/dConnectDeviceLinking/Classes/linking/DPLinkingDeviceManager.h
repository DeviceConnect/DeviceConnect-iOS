//
//  DPLinkingDeviceManager.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#import "DPLinkingDevice.h"
#import "DPLinkingSensorData.h"

@protocol DPLinkingDeviceConnectDelegate <NSObject>
@optional
- (void) didDiscoveryPeripheral:(CBPeripheral *)peripheral;
- (void) didConnectedDevice:(DPLinkingDevice *)device;
- (void) didFailToConnectDevice:(DPLinkingDevice *)device;
- (void) didDisonnectedDevice:(DPLinkingDevice *)device;
- (void) didRemovedDeviceAll;
@end


@protocol DPLinkingDeviceSensorDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device sensor:(DPLinkingSensorData *)data;
@end


@protocol DPLinkingDeviceButtonIdDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device buttonId:(int)buttonId;
@end


@protocol DPLinkingDeviceBatteryDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device lowBattery:(BOOL)lowBattery level:(float)level;
@end


@protocol DPLinkingDeviceTemperatureDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device temperature:(float)temperature;
@end


@protocol DPLinkingDeviceHumidityDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device humidity:(float)humidity;
@end


@protocol DPLinkingDeviceAtmosphericPressureDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device atmosphericPressure:(float)atmosphericPressure;
@end


@protocol DPLinkingDeviceRangeDelegate <NSObject>
@optional
- (void) didReceivedDevice:(DPLinkingDevice *)device range:(DPLinkingRange)range;
@end


@interface DPLinkingDeviceManager : NSObject

+ (DPLinkingDeviceManager *) sharedInstance;

- (void) startScan;
- (void) stopScan;
- (BOOL) isStartScan;

- (void) restart;

- (NSArray *) getDPLinkingDevices;

- (DPLinkingDevice *) createDPLinkingDevice:(CBPeripheral *)peripheral;
- (void) removeDPLinkingDeviceAtIndex:(int)index;
- (void) removeDPLinkingDevice:(DPLinkingDevice *)device;
- (void) removeAllDPLinkingDevice;

- (DPLinkingDevice *) findDPLinkingDeviceByPeripheral:(CBPeripheral *)peripheral;
- (DPLinkingDevice *) findDPLinkingDeviceByServiceId:(NSString *)serviceId;

- (void) connectDPLinkingDevice:(DPLinkingDevice *)device;
- (void) disconnectDPLinkingDevice:(DPLinkingDevice *)device;

- (void) sendLEDCommand:(DPLinkingDevice *)device power:(BOOL)on;
- (void) sendVibrationCommand:(DPLinkingDevice *)device power:(BOOL)on;
- (void) sendNotification:(DPLinkingDevice *)device title:(NSString *)title message:(NSString *)message;

- (void) enableListenSensor:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceSensorDelegate>)delegate;
- (void) disableListenSensor:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceSensorDelegate>)delegate;
- (BOOL) isListenSensor;

- (void) enableListenButtonId:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceButtonIdDelegate>)delegate;
- (void) disableListenButtonId:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceButtonIdDelegate>)delegate;

- (void) enableListenRange:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceRangeDelegate>)delegate;
- (void) disableListenRange:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceRangeDelegate>)delegate;

- (void) enableListenBattery:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceBatteryDelegate>)delegate;
- (void) disableListenBattery:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceBatteryDelegate>)delegate;

- (void) enableListenTemperature:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceTemperatureDelegate>)delegate;
- (void) disableListenTemperature:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceTemperatureDelegate>)delegate;

- (void) enableListenHumidity:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceHumidityDelegate>)delegate;
- (void) disableListenHumidity:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceHumidityDelegate>)delegate;

- (void) enableListenAtmosphericPressure:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceAtmosphericPressureDelegate>)delegate;
- (void) disableListenAtmosphericPressure:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceAtmosphericPressureDelegate>)delegate;

- (void) setDefaultLED:(DPLinkingDevice *)device;
- (void) setDefaultVibration:(DPLinkingDevice *)device;

- (void) addConnectDelegate:(id<DPLinkingDeviceConnectDelegate>)delegate;
- (void) removeConnectDelegate:(id<DPLinkingDeviceConnectDelegate>)delegate;

@end
