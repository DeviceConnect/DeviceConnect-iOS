//
//  DPLinkingDeviceManager.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceManager.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingUtil.h"

static const NSInteger kDistanceThresholdImmediate = 3.0f;
static const NSInteger kDistanceThresholdNear = 10.0f;
static const NSInteger kDistanceThresholdFar = 20.0f;

@interface DPLinkingDeviceManager() <BLEDelegateModelDelegate>

@property (nonatomic) NSMutableArray *devices;
@property (nonatomic) NSMutableArray *connectDelegates;

@property (nonatomic) NSMutableDictionary *sensorDic;
@property (nonatomic) NSMutableDictionary *buttonIdDic;
@property (nonatomic) NSMutableDictionary *rangeDic;

@property (nonatomic) NSMutableDictionary *batteryDic;
@property (nonatomic) NSMutableDictionary *temperatureDic;
@property (nonatomic) NSMutableDictionary *humidityDic;
@property (nonatomic) NSMutableDictionary *atmospheircPressureDic;

@property (nonatomic) DPLinkingDevice *connectingDevice;

@end


@implementation DPLinkingDeviceManager {
    DPLinkingUtilTimerCancelBlock _scanTimerCancelBlock;
    DPLinkingUtilTimerCancelBlock _connectingCancelBlock;
    BOOL _initFlag;
}

static DPLinkingDeviceManager* _sharedInstance = nil;

+ (DPLinkingDeviceManager *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [DPLinkingDeviceManager new];
    });
    return _sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.devices = [NSMutableArray array];
        self.connectDelegates = [NSMutableArray array];
        
        self.sensorDic = [NSMutableDictionary dictionary];
        self.buttonIdDic = [NSMutableDictionary dictionary];
        self.rangeDic = [NSMutableDictionary dictionary];
        self.batteryDic = [NSMutableDictionary dictionary];
        self.temperatureDic = [NSMutableDictionary dictionary];
        self.humidityDic = [NSMutableDictionary dictionary];
        self.atmospheircPressureDic = [NSMutableDictionary dictionary];
        
        [[BLEConnecter sharedInstance] addListener:self deviceUUID:nil];
        [self loadDPLinkingDevice];
        
        __weak typeof(self) weakSelf = self;
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf startScanWithTimeout:20];
        });
    }
    return self;
}

#pragma mark - Public Method

- (void) startScan {
    if ([BLEConnecter sharedInstance].canDiscovery) {
        DCLogInfo(@"startScan");
        [[BLEConnecter sharedInstance] scanDevice];
    } else {
        DCLogWarn(@"Cannot start a scan.");
    }
}

- (void) stopScan {
    if ([[BLEConnecter sharedInstance] isCanDiscovery] && ![[DPLinkingBeaconManager sharedInstance] isStartBeaconScan]) {
        DCLogInfo(@"stopScan");
        [[BLEConnecter sharedInstance] stopScan];
    } else {
        DCLogWarn(@"Cannot stop scan. Scan is not running.");
    }
}

- (BOOL) isStartScan {
    return [[BLEConnecter sharedInstance] isCanDiscovery];
}

- (void) restart {
    [self startScanWithTimeout:20];
}

- (DPLinkingDevice *) findDPLinkingDeviceByPeripheral:(CBPeripheral *)peripheral {
    __block DPLinkingDevice *result = nil;
    [self.devices enumerateObjectsUsingBlock:^(DPLinkingDevice *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:peripheral.identifier.UUIDString]) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (DPLinkingDevice *) findDPLinkingDeviceByServiceId:(NSString *)serviceId {
    __block DPLinkingDevice *result = nil;
    [self.devices enumerateObjectsUsingBlock:^(DPLinkingDevice *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:serviceId]) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (NSArray *) getDPLinkingDevices {
    return self.devices;
}

- (DPLinkingDevice *) createDPLinkingDevice:(CBPeripheral *)peripheral {
    DPLinkingDevice *device = [[DPLinkingDevice alloc] init];
    device.name = peripheral.name;
    device.identifier = peripheral.identifier.UUIDString;
    device.online = NO;
    [self addDPLinkingDevice:device];
    return device;
}

- (void) removeDPLinkingDeviceAtIndex:(int)index {
    if (index < 0 || index > [self.devices count] - 1) {
        return;
    }
    
    DPLinkingDevice *device = [self.devices objectAtIndex:index];
    [self removeDPLinkingDevice:device];
}

- (void) removeDPLinkingDevice:(DPLinkingDevice *)device {
    if (!device) {
        return;
    }

    DCLogInfo(@"removeDPLinkingDevice %@", device.name);
    if (device.online) {
        [self disconnectDPLinkingDevice:device];
    }
    
    [self.devices removeObject:device];
    [self saveDPLinkingDevice];
}

- (void) removeAllDPLinkingDevice {
    [[BLEConnecter sharedInstance] disconnectAll];
    [[BLERequestController sharedInstance] deleteDevices];
    [self.devices removeAllObjects];
    [self saveDPLinkingDevice];
    
    [self notifyRemovedDeviceAll];
}

- (void) connectDPLinkingDevice:(DPLinkingDevice *)device {
    __weak typeof(self) weakSelf = self;

    self.connectingDevice = device;

    if (device.peripheral) {
        DCLogInfo(@"connectDPLinkingDevice: %@", device.peripheral);
        
        _connectingCancelBlock = [DPLinkingUtil asyncAfterDelay:60.0 block:^{
            [weakSelf notifyFailToConnectDevice:device];
            [weakSelf disconnectDPLinkingDevice:device];
            weakSelf.connectingDevice = nil;
        }];
        [[BLEConnecter sharedInstance] connectDevice:device.peripheral];
    } else {
        _scanTimerCancelBlock = [DPLinkingUtil asyncAfterDelay:10.0 block:^{
            [weakSelf notifyFailToConnectDevice:device];
            [weakSelf stopScan];
            weakSelf.connectingDevice = nil;
        }];
        [self startScan];
    }
    device.connectFlag = YES;
    [self saveDPLinkingDevice];
}

- (void) disconnectDPLinkingDevice:(DPLinkingDevice *)device {
    DCLogInfo(@"disconnectDPLinkingDevice: %@", device);
    
    if (device.online) {
        // TODO: 何か処理が必要か検討
    }
    
    [[BLEConnecter sharedInstance] disconnectByDeviceUUID:device.peripheral.identifier.UUIDString];
    device.connectFlag = NO;
    device.peripheral = nil;
    [self saveDPLinkingDevice];
}

- (void) sendLEDCommand:(DPLinkingDevice *)device power:(BOOL)on {
    BLERequestController *request = [BLERequestController sharedInstance];
    if (on) {
        [request startDemoSelectSettingInformationWithLED:device.setting.settingInformationDataLED
                                                vibration:nil
                                              notifySound:nil
                                               peripheral:device.peripheral
                                               disconnect:NO];
    } else {
        [request stopDemoSelectSettingInformationWithLED:nil
                                               vibration:nil
                                             notifySound:nil
                                              peripheral:device.peripheral
                                              disconnect:NO];
    }
}

- (void) sendVibrationCommand:(DPLinkingDevice *)device power:(BOOL)on {
    BLERequestController *request = [BLERequestController sharedInstance];
    if (on) {
        [request startDemoSelectSettingInformationWithLED:nil
                                                vibration:device.setting.settingInformationDataVibration
                                              notifySound:nil
                                               peripheral:device.peripheral
                                               disconnect:NO];
    } else {
        [request stopDemoSelectSettingInformationWithLED:nil
                                               vibration:nil
                                             notifySound:nil
                                              peripheral:device.peripheral
                                              disconnect:NO];
    }
}

- (void) setDefaultLED:(DPLinkingDevice *)device {
    [[BLERequestController sharedInstance] setSelectSettingInformationWithLED:device.setting.settingInformationDataLED
                                                                    vibration:nil
                                                                  notifySound:nil
                                                                   peripheral:device.peripheral
                                                                   disconnect:NO];
}

- (void) setDefaultVibration:(DPLinkingDevice *)device {
    [[BLERequestController sharedInstance] setSelectSettingInformationWithLED:nil
                                                                    vibration:device.setting.settingInformationDataVibration
                                                                  notifySound:nil
                                                                   peripheral:device.peripheral
                                                                   disconnect:NO];
}

- (void) sendNotification:(DPLinkingDevice *)device title:(NSString *)title message:(NSString *)message {
    // TODO: 設定が反映されない。
    NSString *appName = @"Linking Plugin";
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    BLEDeviceNotificationSetting * dnSetting = [BLEDeviceNotificationSetting new];
    dnSetting.title = title;
    dnSetting.text = message;
    dnSetting.appName = appName;
    dnSetting.appNameLocal = appName;
    dnSetting.package = bundleId;
    dnSetting.notifyId = 0;
    dnSetting.notifyCategoryId = 0;
    dnSetting.ledSetting = YES;
    dnSetting.vibrationSetting = YES;
    dnSetting.led = nil;
    dnSetting.vibration = nil;
    dnSetting.deviceId = device.setting.deviceId;
    dnSetting.deviceUId = nil;
    BLERequestController *request = [BLERequestController sharedInstance];
    [request sendGeneralInformation:dnSetting
                         peripheral:device.peripheral
                         disconnect:NO];
}

- (void) enableListenSensor:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceSensorDelegate>)delegate {
    if (![device isSupportSensor]) {
        return;
    }
    
    NSMutableArray *array = [self.sensorDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.sensorDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
    
    if (array.count > 1) {
        return;
    }
    
    DCLogInfo(@"sensor start.");
    
    BLERequestController *request = [BLERequestController sharedInstance];
    if ([device isSupportGryo ]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeGyroscope
                                     status:DPLinkingSensorStatusStart
                                 disconnect:NO];
    }
    if ([device isSupportAcceleration]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeAccelerometer
                                     status:DPLinkingSensorStatusStart
                                 disconnect:NO];
    }
    if ([device isSupportCompass]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeOrientation
                                     status:DPLinkingSensorStatusStart
                                 disconnect:NO];
    }
}

- (void) disableListenSensor:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceSensorDelegate>)delegate {
    NSMutableArray *array = [self.sensorDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.sensorDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
    
    DCLogInfo(@"sensor stop.");

    BLERequestController *request = [BLERequestController sharedInstance];
    if ([device isSupportGryo ]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeGyroscope
                                     status:DPLinkingSensorStatusStop
                                 disconnect:NO];
    }
    if ([device isSupportAcceleration]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeAccelerometer
                                     status:DPLinkingSensorStatusStop
                                 disconnect:NO];
    }
    if ([device isSupportCompass]) {
        [request setNotifySensorInfoMessage:device.peripheral
                                 sensorType:DPLinkingSensorTypeOrientation
                                     status:DPLinkingSensorStatusStop
                                 disconnect:NO];
    }
}

- (BOOL) isListenSensor {
    return self.sensorDic.count > 0;
}

- (void) enableListenButtonId:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceButtonIdDelegate>)delegate {
    if (![device isSupportButtonId]) {
        return;
    }
    
    NSMutableArray *array = [self.buttonIdDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.buttonIdDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
}

- (void) disableListenButtonId:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceButtonIdDelegate>)delegate {
    NSMutableArray *array = [self.buttonIdDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.buttonIdDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
}

- (void) enableListenRange:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceRangeDelegate>)delegate {
    NSMutableArray *array = [self.rangeDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.rangeDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
}

- (void) disableListenRange:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceRangeDelegate>)delegate {
    NSMutableArray *array = [self.rangeDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.rangeDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
}

- (void) enableListenBattery:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceBatteryDelegate>)delegate {
    if (![device isSupportBattery]) {
        return;
    }
    
    NSMutableArray *array = [self.batteryDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.batteryDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
    
    if (array.count > 1) {
        return;
    }
    
    DCLogInfo(@"battery sensor start. device=%@", device.name);
    
    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeBattery
                                 status:DPLinkingSensorStatusStart
                             disconnect:NO];
}

- (void) disableListenBattery:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceBatteryDelegate>)delegate {
    if (![device isSupportBattery]) {
        return;
    }

    NSMutableArray *array = [self.batteryDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.batteryDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
    
    DCLogInfo(@"battery sensor stop. device=%@", device.name);

    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeBattery
                                 status:DPLinkingSensorStatusStop
                             disconnect:NO];
}

- (void) enableListenTemperature:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceTemperatureDelegate>)delegate {
    if (![device isSupportTemperature]) {
        return;
    }
        
    NSMutableArray *array = [self.temperatureDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.temperatureDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
    
    if (array.count > 1) {
        return;
    }

    DCLogInfo(@"temperature sensor start. device=%@", device.name);

    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeTemperature
                                 status:DPLinkingSensorStatusStart
                             disconnect:NO];
}

- (void) disableListenTemperature:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceTemperatureDelegate>)delegate {
    if (![device isSupportTemperature]) {
        return;
    }
    
    NSMutableArray *array = [self.temperatureDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.temperatureDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
    
    DCLogInfo(@"temperature sensor stop. device=%@", device.name);

    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeTemperature
                                 status:DPLinkingSensorStatusStop
                             disconnect:NO];
}

- (void) enableListenHumidity:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceHumidityDelegate>)delegate {
    if (![device isSupportHumidity]) {
        return;
    }

    NSMutableArray *array = [self.humidityDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.humidityDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
    
    if (array.count > 1) {
        return;
    }

    DCLogInfo(@"humidity sensor start. device=%@", device.name);

    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeHumidity
                                 status:DPLinkingSensorStatusStart
                             disconnect:NO];
}

- (void) disableListenHumidity:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceHumidityDelegate>)delegate {
    if (![device isSupportHumidity]) {
        return;
    }
    
    NSMutableArray *array = [self.humidityDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.humidityDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
    
    DCLogInfo(@"humidity sensor stop. device=%@", device.name);

    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeHumidity
                                 status:DPLinkingSensorStatusStop
                             disconnect:NO];
}

- (void) enableListenAtmosphericPressure:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceAtmosphericPressureDelegate>)delegate {
    if (![device isSupportAtmosphericPressure]) {
        return;
    }

    NSMutableArray *array = [self.atmospheircPressureDic objectForKey:device.identifier];
    if (!array) {
        array = [NSMutableArray array];
        [self.atmospheircPressureDic setObject:array forKey:device.identifier];
    } else if ([array containsObject:delegate]) {
        return;
    }
    [array addObject:delegate];
    
    if (array.count > 1) {
        return;
    }
    
    DCLogInfo(@"atmospheric pressure sensor start. device=%@", device.name);
    
    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeAtmosphericPressure
                                 status:DPLinkingSensorStatusStart
                             disconnect:NO];
}

- (void) disableListenAtmosphericPressure:(DPLinkingDevice *)device delegate:(id<DPLinkingDeviceAtmosphericPressureDelegate>)delegate {
    if (![device isSupportAtmosphericPressure]) {
        return;
    }
    
    NSMutableArray *array = [self.atmospheircPressureDic objectForKey:device.identifier];
    if (!array || array.count == 0) {
        return;
    } else {
        [array removeObject:delegate];
        if (array.count == 0) {
            [self.atmospheircPressureDic removeObjectForKey:device.identifier];
        } else {
            return;
        }
    }
    
    DCLogInfo(@"atmospheric pressure sensor stop. device=%@", device.name);
    
    BLERequestController *request = [BLERequestController sharedInstance];
    [request setNotifySensorInfoMessage:device.peripheral
                             sensorType:DPLinkingSensorTypeAtmosphericPressure
                                 status:DPLinkingSensorStatusStop
                             disconnect:NO];
}

- (void) addConnectDelegate:(id<DPLinkingDeviceConnectDelegate>)delegate {
    [self.connectDelegates addObject:delegate];
}

- (void) removeConnectDelegate:(id<DPLinkingDeviceConnectDelegate>)delegate {
    [self.connectDelegates removeObject:delegate];
}


#pragma mark - Private Method

- (void) startScanWithTimeout:(NSTimeInterval)timeout {
    if ([BLEConnecter sharedInstance].canDiscovery) {
        DCLogInfo(@"DPLinkingDeviceManager::startScanWithTimeout");
        [DPLinkingUtil asyncAfterDelay:timeout block:^{
            DCLogWarn(@"Timeout.");
            _initFlag = NO;
            if (![[DPLinkingBeaconManager sharedInstance] isStartBeaconScan]) {
                [[BLEConnecter sharedInstance] stopScan];
            }
        }];
        _initFlag = YES;
        [[BLEConnecter sharedInstance] scanDevice];
    } else {
        DCLogWarn(@"Cannot start a scan.");
    }
}

- (void) addDPLinkingDevice:(DPLinkingDevice *)device {
    [self.devices addObject:device];
    [self saveDPLinkingDevice];
}

- (void) saveDPLinkingDevice {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"LinkingDevice.dat"];

    NSMutableData *data = [NSMutableData data];

    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder encodeObject:self.devices forKey:@"devices"];
    [encoder finishEncoding];
    
    [data writeToFile:path atomically:YES];
}

- (void) loadDPLinkingDevice {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"LinkingDevice.dat"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSMutableData *data  = [NSMutableData dataWithContentsOfFile:path];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.devices = [decoder decodeObjectForKey:@"devices"];
    }
}

- (void) notifyButtonId:(int)buttonId device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.buttonIdDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceButtonIdDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:buttonId:)]) {
                [obj didReceivedDevice:device buttonId:buttonId];
            }
        }];
    }
}

- (void) notifySensor:(DPLinkingSensorData *)sensor device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.sensorDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceSensorDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:sensor:)]) {
                [obj didReceivedDevice:device sensor:sensor];
            }
        }];
    }
}

- (void) notifyRange:(DPLinkingRange)range device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.rangeDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceRangeDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:range:)]) {
                [obj didReceivedDevice:device range:range];
            }
        }];
    }
}

- (void) notifyConnectDevice:(DPLinkingDevice *)device {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingDeviceConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didConnectedDevice:)]) {
            [obj didConnectedDevice:device];
        }
    }];
}

- (void) notifyFailToConnectDevice:(DPLinkingDevice *)device {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingDeviceConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didFailToConnectDevice:)]) {
            [obj didFailToConnectDevice:device];
        }
    }];
}

- (void) notifyDisconnectDevice:(DPLinkingDevice *)device {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingDeviceConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didDisonnectedDevice:)]) {
            [obj didDisonnectedDevice:device];
        }
    }];
}

- (void) notifyDiscoveryPeripheral:(CBPeripheral *)peripheral {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingDeviceConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didDiscoveryPeripheral:)]) {
            [obj didDiscoveryPeripheral:peripheral];
        }
    }];
}

- (void) notifyRemovedDeviceAll {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingDeviceConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didRemovedDeviceAll)]) {
            [obj didRemovedDeviceAll];
        }
    }];
}

- (void) notifyTemperature:(float)temperature device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.temperatureDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceTemperatureDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:temperature:)]) {
                [obj didReceivedDevice:device temperature:temperature];
            }
        }];
    }
}

- (void) notifyHumidity:(float)humidity device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.humidityDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceHumidityDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:humidity:)]) {
                [obj didReceivedDevice:device humidity:humidity];
            }
        }];
    }
}

- (void) notifyAtmosphericPressure:(float)atmosphericPressure device:(DPLinkingDevice *)device {
    NSMutableArray *array = [self.atmospheircPressureDic objectForKey:device.identifier];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id<DPLinkingDeviceAtmosphericPressureDelegate> obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceivedDevice:atmosphericPressure:)]) {
                [obj didReceivedDevice:device atmosphericPressure:atmosphericPressure];
            }
        }];
    }
}

- (BOOL) isEqualDeviceUuid:(CBPeripheral *)peripheral {
    return self.connectingDevice && [self.connectingDevice.identifier isEqualToString:peripheral.identifier.UUIDString];
}

- (void) cancelConnectingDevice:(CBPeripheral *)peripheral {
    if ([self isEqualDeviceUuid:peripheral]) {
        if (_connectingCancelBlock) {
            _connectingCancelBlock();
            _connectingCancelBlock = nil;
        }
        self.connectingDevice = nil;
    }
}

- (void) failToConnect:(CBPeripheral *)peripheral {
    BLEDeviceSetting *setting = [[BLEConnecter sharedInstance] getDeviceByPeripheral:peripheral];
    
    DCLogInfo(@"@@ failToConnect: [デバイス：%@ との接続に失敗しました。]", setting.name);
    DCLogInfo(@"    setting.notifyDeviceInitial: %@", setting.notifyDeviceInitial ? @"YES" : @"NO");
    DCLogInfo(@"    setting.initialDeviceSettingFinished: %@", setting.initialDeviceSettingFinished ? @"YES" : @"NO");
    DCLogInfo(@"    setting.saved: %@", setting.saved ? @"YES" : @"NO");
    DCLogInfo(@"    setting.connectionStatus: %@", setting.connectionStatus);
    
    if ([self isEqualDeviceUuid:peripheral]) {
        DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
        if (device) {
            device.setting = setting;
            device.online = NO;
            
            [self notifyFailToConnectDevice:device];
        }
    }
    [self cancelConnectingDevice:peripheral];
}

#pragma mark - BLEConnecterDelegate

- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        device.peripheral = peripheral;

        if ([self isEqualDeviceUuid:peripheral]) {
            if (_scanTimerCancelBlock) {
                _scanTimerCancelBlock();
                _scanTimerCancelBlock = nil;
            }
            [self stopScan];
            [self connectDPLinkingDevice:device];
        } else if (_initFlag) {
            if (device.connectFlag && !device.online) {
                [self connectDPLinkingDevice:device];
            }
        }
    }
    
    [self notifyDiscoveryPeripheral:peripheral];
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    DCLogInfo(@"@@ didConnectPeripheral %@", peripheral);
}

- (void) didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DCLogInfo(@"@@ didFailToConnectPeripheral %@", peripheral.identifier.UUIDString);
    [self failToConnect:peripheral];
}

- (void)didConnectDevice:(BLEDeviceSetting *)setting {
    DCLogInfo(@"@@ didConnectDevice: [デバイス：%@ と接続されました。]", setting.name);
    DCLogInfo(@"    setting.notifyDeviceInitial: %@", setting.notifyDeviceInitial ? @"YES" : @"NO");
    DCLogInfo(@"    setting.initialDeviceSettingFinished: %@", setting.initialDeviceSettingFinished ? @"YES" : @"NO");
    DCLogInfo(@"    setting.saved: %@", setting.saved ? @"YES" : @"NO");
    DCLogInfo(@"    setting.connectionStatus: %@", setting.connectionStatus);

    setting.inDistanceThreshold = YES;
}

- (void)didDeviceInitialFinished:(CBPeripheral *)peripheral {
    DCLogInfo(@"@@ didDeviceInitialFinished %@", peripheral);
    
    BLEDeviceSetting *setting = [[BLEConnecter sharedInstance] getDeviceByPeripheral:peripheral];

    DCLogInfo(@"デバイスの初期化が完了しました");
    DCLogInfo(@"    name : %@", setting.peripheral.name);
    DCLogInfo(@"    device id : %d", setting.deviceId);
    DCLogInfo(@"    device uid : %d", setting.deviceUid);
    DCLogInfo(@"    device hasLED : %@", setting.hasLED ? @"YES" : @"NO");
    DCLogInfo(@"    device hasGyroscope : %@", setting.hasGyroscope ? @"YES" : @"NO");
    DCLogInfo(@"    device hasAccelerometer : %@", setting.hasAccelerometer ? @"YES" : @"NO");
    DCLogInfo(@"    device hasOrientation : %@", setting.hasOrientation ? @"YES" : @"NO");
    DCLogInfo(@"    device exSensorType: %@", setting.exSensorType);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:setting.peripheral];
    if (device) {
        setting.distanceThreshold = kDistanceThresholdNear;
        device.setting = setting;
        device.peripheral = setting.peripheral;
        device.online = YES;
        
        [self notifyConnectDevice:device];
    }
    [self cancelConnectingDevice:peripheral];
    
    // BLEConnector::connectDeviceを行うとscanが止まってしまうので、終了した後にスキャンを再開する
    if (_initFlag || [[DPLinkingBeaconManager sharedInstance] isStartBeaconScan]) {
        [[BLEConnecter sharedInstance] scanDevice];
    }
}

- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    DCLogInfo(@"@@ didDisconnectPeripheral: %@", peripheral);

    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        device.online = NO;
    }
}

- (void) didDisconnectDevice:(BLEDeviceSetting *)setting {
    DCLogInfo(@"@@ didDisconnectDevice: %@", setting.peripheral);

    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:setting.peripheral];
    if (device) {
        device.online = NO;
        [self notifyDisconnectDevice:device];
    }
}

- (void)didTimeOutPeripheral:(CBPeripheral*)peripheral {
    DCLogInfo(@"@@ didTimeOutPeripheral %@", peripheral);
    [self failToConnect:peripheral];
}

- (void)didFailToWrite:(CBPeripheral *)peripheral error:(NSError *)error {
    DCLogInfo(@"@@ didFailToWrite: %@", peripheral);
    DCLogInfo(@"%@", error);
}


#pragma mark - BLEConnecterDelegate RSSI

- (void)didDeviceChangeRSSIValue:(CBPeripheral *)peripheral
                            RSSI:(NSNumber *)RSSI
                     inThreshold:(BOOL)isInRSSIThreshold
{
    DCLogInfo(@"@@@@@@@@@@ didDeviceChangeRSSIValue: %@ %d", RSSI, isInRSSIThreshold);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        if (device.setting.distanceThreshold <= kDistanceThresholdImmediate) {
            if (isInRSSIThreshold) {
                [self notifyRange:DPLinkingRangeImmediate device:device];
            } else {
                [self notifyRange:DPLinkingRangeNear device:device];
            }
        } else if (device.setting.distanceThreshold <= kDistanceThresholdNear) {
            if (isInRSSIThreshold) {
                [self notifyRange:DPLinkingRangeImmediate device:device];
            } else {
                [self notifyRange:DPLinkingRangeNear device:device];
            }
        } else if (device.setting.distanceThreshold <= kDistanceThresholdFar) {
            if (isInRSSIThreshold) {
                [self notifyRange:DPLinkingRangeNear device:device];
            } else {
                [self notifyRange:DPLinkingRangeFar device:device];
            }
        }
    }
}

- (void)isBelowTheThreshold:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI {
    DCLogInfo(@"%@は範囲外にいます : %@", peripheral.name, RSSI);
}

#pragma mark - BLEConnecterDelegate ButtonId

- (void)deviceButtonPushed:(CBPeripheral *)peripheral buttonID:(char)buttonID {
    DCLogInfo(@"ボタン %d が操作されました。", buttonID);

    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        [self notifyButtonId:buttonID device:device];
    }
}

#pragma mark - BLEConnecterDelegate Sensor

- (void)gyroscopeDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorGyroscope *)sensor {
    DCLogInfo(@"ジャイロセンサーのデータを取得しました。");
    DCLogInfo(@"x : %f", sensor.xValue);
    DCLogInfo(@"y : %f", sensor.yValue);
    DCLogInfo(@"z : %f", sensor.zValue);
    DCLogInfo(@"originalData : %@", sensor.originalData);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        DPLinkingSensorData *data = [[DPLinkingSensorData alloc] init];
        data.type = DPLinkingSensorTypeGyroscope;
        data.x = sensor.xValue;
        data.y = sensor.yValue;
        data.z = sensor.zValue;
        data.timeStamp = [NSDate date].timeIntervalSince1970;
        [self notifySensor:data device:device];
    }
}

- (void)gyroscopeDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorGyroscope *)sensor {
    DCLogInfo(@"定期受信-ジャイロセンサーのデータを取得しました。");
}

- (void)gyroscopeDidUpDateDelegate:(CBPeripheral *)peripheral {
    DCLogInfo(@"ジャイロセンサーの取得が終了しました。");
}

- (void)gyroscopeObservationEnded:(CBPeripheral *)peripheral {
    DCLogInfo(@"gyroscopeObservationEnded");
}

- (void)accelerometerDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAccelerometer *)sensor {
    DCLogInfo(@"加速度センサーのデータを取得しました。");
    DCLogInfo(@"x : %f", sensor.xValue);
    DCLogInfo(@"y : %f", sensor.yValue);
    DCLogInfo(@"z : %f", sensor.zValue);
    DCLogInfo(@"originalData) : %@", sensor.originalData);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        DPLinkingSensorData *data = [[DPLinkingSensorData alloc] init];
        data.type = DPLinkingSensorTypeAccelerometer;
        data.x = sensor.xValue;
        data.y = sensor.yValue;
        data.z = sensor.zValue;
        data.timeStamp = [NSDate date].timeIntervalSince1970;
        [self notifySensor:data device:device];
    }
}

- (void)accelerometerDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAccelerometer *)sensor {
    DCLogInfo(@"定期受信-加速度センサーのデータを取得しました。");
}

- (void)accelerometerDidUpDateDelegate:(CBPeripheral *)peripheral {
    DCLogInfo(@"加速度センサーの取得が終了しました。");
}

- (void)accelerometerObservationEnded:(CBPeripheral *)peripheral {
    DCLogInfo(@"accelerometerObservationEnded");
}

- (void) orientationDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorOrientation *)sensor {
    DCLogInfo(@"方位センサーのデータを取得しました。");
    DCLogInfo(@"x : %f", sensor.xValue);
    DCLogInfo(@"y : %f", sensor.yValue);
    DCLogInfo(@"z : %f", sensor.zValue);
    DCLogInfo(@"originalData : %@", sensor.originalData);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        DPLinkingSensorData *data = [[DPLinkingSensorData alloc] init];
        data.type = DPLinkingSensorTypeOrientation;
        data.x = sensor.xValue;
        data.y = sensor.yValue;
        data.z = sensor.zValue;
        data.timeStamp = [NSDate date].timeIntervalSince1970;
        [self notifySensor:data device:device];
    }
}

- (void) orientationDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorOrientation *)sensor {
    DCLogInfo(@"定期受信-方位センサーのデータを取得しました。");
}

- (void) orientationObservationEnded:(CBPeripheral *)peripheral {
    DCLogInfo(@"方位センサーの取得が終了しました。");
}

#pragma mark - BLEConnecterDelegate Temperature

- (void)temperatureDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorTemperature *)sensor; {
    NSLog(@"temperatureDidUpDateDelegate: %@", sensor);
    
    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        int value = [DPLinkingUtil byteToShort:sensor.originalData.bytes];
        float temperature = [DPLinkingUtil intToFloat:value fraction:7 exponent:4 sign:YES];
        [self notifyTemperature:temperature device:device];
    }
}

- (void)temperatureDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorTemperature *)sensor {
    NSLog(@"temperatureDidUpDateWithIntervalDelegate: %@", sensor);
}

- (void)temperatureDidUpDateDelegate:(CBPeripheral *)peripheral {
    NSLog(@"temperatureDidUpDateWithIntervalDelegate");
}

#pragma mark - BLEConnecterDelegate Humidiy

- (void)humidityDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorHumidity *)sensor {
    NSLog(@"humidityDidUpDateDelegate: %@", sensor);

    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        int value = [DPLinkingUtil byteToShort:sensor.originalData.bytes];
        float humidity = [DPLinkingUtil intToFloat:value fraction:8 exponent:4 sign:NO];
        [self notifyHumidity:humidity device:device];
    }
}

- (void)humidityDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorHumidity *)sensor {
    NSLog(@"humidityDidUpDateWithIntervalDelegate: %@", sensor);
}

- (void)humidityDidUpDateDelegate:(CBPeripheral*)peripheral {
    NSLog(@"humidityDidUpDateDelegate");
}

#pragma mark - BLEConnecterDelegate AtmosphericPressure

- (void)atmosphericPressureDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAtmosphericPressure *)sensor {
    NSLog(@"atmosphericPressureDidUpDateDelegate: %@", sensor);

    DPLinkingDevice *device = [self findDPLinkingDeviceByPeripheral:peripheral];
    if (device) {
        int value = [DPLinkingUtil byteToShort:sensor.originalData.bytes];
        float atmosphericPressure = [DPLinkingUtil intToFloat:value fraction:7 exponent:5 sign:NO];
        [self notifyAtmosphericPressure:atmosphericPressure device:device];
    }
}

- (void)atmosphericPressureDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAtmosphericPressure *)sensor {
    NSLog(@"atmosphericPressureDidUpDateWithIntervalDelegate: %@", sensor);
}

- (void)atmosphericPressureDidUpDateDelegate:(CBPeripheral *)peripheral {
    NSLog(@"atmosphericPressureDidUpDateDelegate");
}

@end
