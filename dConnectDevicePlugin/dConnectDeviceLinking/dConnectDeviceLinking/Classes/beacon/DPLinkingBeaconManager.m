//
//  DPLinkingBeaconManager.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconManager.h"
#import "DPLinkingUtil.h"

static const NSInteger kCheckConnectionInterval = 30;

static NSString *const kFileName = @"LinkingBeacon.dat";
static NSString *const kParamBeacons = @"beacons";
static NSString *const kParamScanFlag = @"isStartBeaconScanFlag";

static NSString *const kDate = @"date";
static NSString *const kHeaderIdentifier = @"headerIdentifier";
static NSString *const kIndividualNumber = @"individualNumber";
static NSString *const kServiceID = @"serviceID";
static NSString *const kDistanceInformation = @"distanceInformation";
static NSString *const kVersion = @"version";
static NSString *const kRSSI = @"rssi";
static NSString *const kTxPowerLevel = @"txPowerLevel";
static NSString *const kServiceData = @"serviceData";
static NSString *const kTemperature = @"temperature";
static NSString *const kHumidity = @"humidity";
static NSString *const kAtmosphericPressure = @"atmosphericPressure";
static NSString *const kIsChargingRequired = @"isChargingRequired";
static NSString *const kRemainingPercentage = @"remainingPercentage";
static NSString *const kButtonIdentifier = @"buttonIdentifier";

typedef NS_ENUM(NSInteger, DPLinkingServiceId) {
    DPLinkingServiceIdTemperature= 1,
    DPLinkingServiceIdHumidity = 2,
    DPLinkingServiceIdAtmosphericPressure = 3,
    DPLinkingServiceIdBattery = 4,
    DPLinkingServiceIdButton = 5,
    DPLinkingServiceIdRawData = 15
};

@interface DPLinkingBeaconManager () <BLEDelegateModelDelegate>

@property (nonatomic) NSMutableArray *beacons;

@property (nonatomic) NSMutableArray *eventDelegates;
@property (nonatomic) NSMutableArray *connectDelegates;
@property (nonatomic) NSMutableArray *atmosphericPressureDelegates;
@property (nonatomic) NSMutableArray *temperatureDelegates;
@property (nonatomic) NSMutableArray *humidityDelegates;
@property (nonatomic) NSMutableArray *batteryDelegates;
@property (nonatomic) NSMutableArray *gattDataDelegates;
@property (nonatomic) NSMutableArray *rawDataDelegates;
@property (nonatomic) NSMutableArray *buttonIdDelegates;

@end

@implementation DPLinkingBeaconManager {
    BOOL _isStartBeaconScanFlag;
    BOOL _isStartBeaconScanTimeoutFlag;
    dispatch_source_t _checkConnectionTimer;
    DPLinkingUtilTimerCancelBlock _cancelBlock;
}

static DPLinkingBeaconManager* _sharedInstance = nil;

+ (DPLinkingBeaconManager *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [DPLinkingBeaconManager new];
    });
    return _sharedInstance;
}



- (id) init {
    self = [super init];
    if (self) {
        self.beacons = [[NSMutableArray alloc] init];
        self.eventDelegates = [[NSMutableArray alloc] init];
        self.connectDelegates = [[NSMutableArray alloc] init];
        self.atmosphericPressureDelegates = [[NSMutableArray alloc] init];
        self.temperatureDelegates = [[NSMutableArray alloc] init];
        self.humidityDelegates = [[NSMutableArray alloc] init];
        self.batteryDelegates = [[NSMutableArray alloc] init];
        self.gattDataDelegates = [[NSMutableArray alloc] init];
        self.rawDataDelegates = [[NSMutableArray alloc] init];
        self.buttonIdDelegates = [[NSMutableArray alloc] init];
        [[BLEConnecter sharedInstance] addListener:self deviceUUID:nil];
        [self loadDPLinkingBeacon];
        [self startCheckConnectionOfBeacon];
        
        if (_isStartBeaconScanFlag) {
            [self startBeaconScanInternal];
        }
    }
    return self;
}

#pragma mark - Public Method

- (DPLinkingBeacon *) findBeaconByExtraId:(long)extraId venderId:(long)vendorId {
    __block DPLinkingBeacon *result = nil;
    [self.beacons enumerateObjectsUsingBlock:^(DPLinkingBeacon *obj, NSUInteger idx, BOOL *stop) {
        if (obj.extraId == extraId && obj.vendorId == vendorId) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (DPLinkingBeacon *) findBeaconByBeaconId:(NSString *)beaconId {
    __block DPLinkingBeacon *result = nil;
    [self.beacons enumerateObjectsUsingBlock:^(DPLinkingBeacon *obj, NSUInteger idx, BOOL *stop) {
        if ([beaconId isEqualToString:obj.beaconId]) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (NSArray *) getBeacons {
    return self.beacons;
}

- (void) removeBeacon:(int)index {
    if (index < 0 || index > [self.beacons count] - 1) {
        return;
    }
    
//    DPLinkingBeacon *beacon = [self.beacons objectAtIndex:index];
//    DCLogInfo(@"removeBeacon %@", beacon.displayName);

    [self.beacons removeObjectAtIndex:index];
    [self saveDPLinkingBeacon];
}

- (void) startBeaconScan {
    [self startBeaconScanInternal];
    _isStartBeaconScanFlag = YES;
    [self saveDPLinkingBeacon];
}

- (void) stopBeaconScan {
    [self stopBeaconScanInternal];
    _isStartBeaconScanFlag = NO;
    [self saveDPLinkingBeacon];
}

- (BOOL) isStartBeaconScan {
    return _isStartBeaconScanFlag;
}

- (void) startBeaconScanWithTimeout:(float)timeout {
    if (_isStartBeaconScanFlag) {
        DCLogWarn(@"beacon scan already started.");
        return;
    }

    DCLogInfo(@"startBeaconScanWithTimeout: %f", timeout);

    if (_isStartBeaconScanTimeoutFlag && _cancelBlock) {
        _cancelBlock();
    }
    
    __weak typeof(self) weakSelf = self;

    _cancelBlock = [DPLinkingUtil asyncAfterDelay:timeout block:^{
        DCLogInfo(@"startBeaconScanWithTimeout: timeout");
        if (!_isStartBeaconScanFlag) {
            [weakSelf stopBeaconScanInternal];
        }
        _isStartBeaconScanTimeoutFlag = NO;
    }];
    [self startBeaconScanInternal];
    _isStartBeaconScanTimeoutFlag = YES;
}

- (void) addBeaconEventDelegate:(id<DPLinkingBeaconEventDelegate>)delegate {
    @synchronized(self.eventDelegates) {
        [self.eventDelegates addObject:delegate];
    }
}

- (void) removeBeaconEventDelegate:(id<DPLinkingBeaconEventDelegate>)delegate {
    @synchronized(self.eventDelegates) {
        [self.eventDelegates removeObject:delegate];
    }
}

- (void) addConnectDelegate:(id<DPLinkingBeaconConnectDelegate>)delegate {
    @synchronized(self.connectDelegates) {
        [self.connectDelegates addObject:delegate];
    }
}

- (void) removeConnectDelegate:(id<DPLinkingBeaconConnectDelegate>)delegate {
    @synchronized(self.connectDelegates) {
        [self.connectDelegates removeObject:delegate];
    }
}

- (void) addAtmosphericPressureDelegate:(id<DPLinkingBeaconAtmosphericPressureDelegate>)delegate {
    @synchronized (self.atmosphericPressureDelegates) {
        [self.atmosphericPressureDelegates addObject:delegate];
    }
}

- (void) removeAtmosphericPressureDelegate:(id<DPLinkingBeaconAtmosphericPressureDelegate>)delegate {
    @synchronized (self.atmosphericPressureDelegates) {
        [self.atmosphericPressureDelegates removeObject:delegate];
    }
}

- (void) addTemperatureDelegate:(id<DPLinkingBeaconTemperatureDelegate>)delegate {
    @synchronized(self.temperatureDelegates) {
        [self.temperatureDelegates addObject:delegate];
    }
}

- (void) removeTemperatureDelegate:(id<DPLinkingBeaconTemperatureDelegate>)delegte {
    @synchronized(self.temperatureDelegates) {
        [self.temperatureDelegates removeObject:delegte];
    }
}

- (void) addHumidityDelegate:(id<DPLinkingBeaconHumidityDelegate>)delegate {
    @synchronized(self.humidityDelegates) {
        [self.humidityDelegates addObject:delegate];
    }
}

- (void) removeHumidityDelegate:(id<DPLinkingBeaconHumidityDelegate>)delegate {
    @synchronized(self.humidityDelegates) {
        [self.humidityDelegates removeObject:delegate];
    }
}

- (void) addGattDataDelegate:(id<DPLinkingBeaconGattDataDelegate>)delegate {
    @synchronized(self.gattDataDelegates) {
        [self.gattDataDelegates addObject:delegate];
    }
}

- (void) removeGattDataDelegate:(id<DPLinkingBeaconGattDataDelegate>)delegate {
    @synchronized(self.gattDataDelegates) {
        [self.gattDataDelegates removeObject:delegate];
    }
}

- (void) addBatteryDelegate:(id<DPLinkingBeaconBatteryDelegate>)delegate {
    @synchronized(self.batteryDelegates) {
        [self.batteryDelegates addObject:delegate];
    }
}

- (void) removeBatteryDelegate:(id<DPLinkingBeaconBatteryDelegate>)delegate {
    @synchronized(self.batteryDelegates) {
        [self.batteryDelegates removeObject:delegate];
    }
}

- (void) addButtonIdDelegate:(id<DPLinkingBeaconButtonIdDelegate>)delegate {
    @synchronized(self.buttonIdDelegates) {
        [self.buttonIdDelegates addObject:delegate];
    }
}

- (void) removeButtonIdDelegate:(id<DPLinkingBeaconButtonIdDelegate>)delegate {
    @synchronized(self.buttonIdDelegates) {
        [self.buttonIdDelegates removeObject:delegate];
    }
}

- (void) addRawDataDelegate:(id<DPLinkingBeaconRawDataDelegate>)delegate {
    @synchronized(self.rawDataDelegates) {
        [self.rawDataDelegates addObject:delegate];
    }
}

- (void) removeRawDataDelegate:(id<DPLinkingBeaconRawDataDelegate>)delegate {
    @synchronized(self.rawDataDelegates) {
        [self.rawDataDelegates removeObject:delegate];
    }
}

#pragma mark - Private Method

- (void) startBeaconScanInternal {
    DCLogInfo(@"startBeaconScanInternal");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BLEConnecter sharedInstance] startPartialScanDevice];
    });
}

- (void) stopBeaconScanInternal {
    DCLogInfo(@"stopBeaconScanInternal");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BLEConnecter sharedInstance] stopPartialScanDevice];
    });
}

- (void) startCheckConnectionOfBeacon {
    __weak typeof(self) weakSelf = self;
    _checkConnectionTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_checkConnectionTimer, dispatch_time(DISPATCH_TIME_NOW, 0), (kCheckConnectionInterval / 2.0) * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_checkConnectionTimer, ^{
        [weakSelf checkConnectionOfBeacon];
    });
    dispatch_resume(_checkConnectionTimer);
}

- (void) stopCheckConnectionOfBeacon {
    dispatch_source_cancel(_checkConnectionTimer);
}

- (void) checkConnectionOfBeacon {
    DCLogInfo(@"DPLinkingBeaconManager::checkConnectionOfBeacon");

    __weak typeof(self) weakSelf = self;
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    [self.beacons enumerateObjectsUsingBlock:^(DPLinkingBeacon *obj, NSUInteger idx, BOOL *stop) {
        if (obj.online) {
            if (now - obj.gattData.timeStamp > kCheckConnectionInterval) {
                obj.online = NO;
                [weakSelf notifyDisconnectBeacon:obj];
            }
        }
    }];
}

- (void) parseGattData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    if (!beacon.gattData) {
        beacon.gattData = [[DPLinkingGattData alloc] init];
    }
    beacon.gattData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;
    beacon.gattData.txPower =[[data objectForKey:kTxPowerLevel] floatValue];
    beacon.gattData.rssi = [data objectForKey:kRSSI];
    beacon.gattData.distance = [[data objectForKey:kDistanceInformation] floatValue];
    
    [self notifyGattData:beacon.gattData beacon:beacon];
}

- (void) parseBatteryData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdBattery &&
        [data.allKeys containsObject:kIsChargingRequired] &&
        [data.allKeys containsObject:kRemainingPercentage]) {
        
        if (!beacon.batteryData) {
            beacon.batteryData = [[DPLinkingBattryData alloc] init];
        }

        beacon.batteryData.lowBatteryFlag = [[data objectForKey:kIsChargingRequired] boolValue];
        beacon.batteryData.batteryLevel = [[data objectForKey:kRemainingPercentage] floatValue];
        beacon.batteryData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;
        
        [self notifyBattery:beacon.batteryData beacon:beacon];
    }
}

- (void) parseAtmosphericPressureData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdAtmosphericPressure &&
        [data.allKeys containsObject:kAtmosphericPressure]) {
        
        if (!beacon.atmosphericPressureData) {
            beacon.atmosphericPressureData = [[DPLinkingAtmosphericPressureData alloc] init];
        }
        
        beacon.atmosphericPressureData.value = [[data objectForKey:kAtmosphericPressure] floatValue];
        beacon.atmosphericPressureData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;
        
        [self notifyAtmosphericPressure:beacon.atmosphericPressureData beacon:beacon];
    }
}

- (void) parseHumidityData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdHumidity &&
        [data.allKeys containsObject:kHumidity]) {
        
        if (!beacon.humidityData) {
            beacon.humidityData = [[DPLinkingHumidityData alloc] init];
        }
        
        beacon.humidityData.value = [[data objectForKey:kHumidity] floatValue];
        beacon.humidityData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;
        
        [self notifyHumidity:beacon.humidityData beacon:beacon];
    }
}

- (void) parseTemperatureData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdTemperature &&
        [data.allKeys containsObject:kTemperature]) {

        if (!beacon.temperatureData) {
            beacon.temperatureData = [[DPLinkingTemperatureData alloc] init];
        }
        
        beacon.temperatureData.value = [[data objectForKey:kTemperature] floatValue];
        beacon.temperatureData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;

        [self notifyTemperature:beacon.temperatureData beacon:beacon];
    }
}

- (void) parseRawData:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdRawData &&
        [data.allKeys containsObject:kServiceData]) {
        if (!beacon.rawData) {
            beacon.rawData = [[DPLinkingRawData alloc] init];
        }
        
        beacon.rawData.value = [[data objectForKey:kServiceData] longValue];
        beacon.rawData.timeStamp = ((NSDate *)[data objectForKey:kDate]).timeIntervalSince1970;
        
        [self notifyRawData:beacon.rawData beacon:beacon];
    }
}

- (void) parseButtonId:(DPLinkingBeacon *)beacon advertisement:(NSDictionary *)data {
    int serviceID = [[data objectForKey:kServiceID] intValue];
    if (serviceID == DPLinkingServiceIdButton &&
        [data.allKeys containsObject:kButtonIdentifier]) {
        short buttonId = [[data objectForKey:kButtonIdentifier] shortValue];
        [self notifyButtonId:buttonId beacon:beacon];
    }
}

- (void) saveDPLinkingBeacon {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:kFileName];
    
    NSMutableData *data = [NSMutableData data];
    
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder encodeObject:@(_isStartBeaconScanFlag) forKey:kParamScanFlag];
    [encoder encodeObject:self.beacons forKey:kParamBeacons];
    [encoder finishEncoding];
    
    [data writeToFile:path atomically:YES];
}

- (void) loadDPLinkingBeacon {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:kFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSMutableData *data  = [NSMutableData dataWithContentsOfFile:path];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _isStartBeaconScanFlag = [[decoder decodeObjectForKey:kParamScanFlag] boolValue];
        self.beacons = [decoder decodeObjectForKey:kParamBeacons];
    }
}

- (void) notifyBeacon:(DPLinkingBeacon *)beacon {
    [self.eventDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconEventDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:)]) {
            [obj didReceivedBeacon:beacon];
        }
    }];
}

- (void) notifyConnectBeacon:(DPLinkingBeacon *)beacon {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didConnectedBeacon:)]) {
            [obj didConnectedBeacon:beacon];
        }
    }];
}

- (void) notifyDisconnectBeacon:(DPLinkingBeacon *)beacon {
    [self.connectDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconConnectDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didDisconnectedBeacon:)]) {
            [obj didDisconnectedBeacon:beacon];
        }
    }];
}

- (void) notifyAtmosphericPressure:(DPLinkingAtmosphericPressureData *)atmosphericPressure beacon:(DPLinkingBeacon *)beacon {
    [self.atmosphericPressureDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconAtmosphericPressureDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:AtmosphericPressure:)]) {
            [obj didReceivedBeacon:beacon AtmosphericPressure:atmosphericPressure];
        }
    }];
}

- (void) notifyTemperature:(DPLinkingTemperatureData *)temperature beacon:(DPLinkingBeacon *)beacon {
    [self.temperatureDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconTemperatureDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:temperature:)]) {
            [obj didReceivedBeacon:beacon temperature:temperature];
        }
    }];
}

- (void) notifyHumidity:(DPLinkingHumidityData *)humidity beacon:(DPLinkingBeacon *)beacon {
    [self.humidityDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconHumidityDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:humidty:)]) {
            [obj didReceivedBeacon:beacon humidty:humidity];
        }
    }];
}

- (void) notifyBattery:(DPLinkingBattryData *)battery beacon:(DPLinkingBeacon *)beacon {
    [self.batteryDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconBatteryDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:battery:)]) {
            [obj didReceivedBeacon:beacon battery:battery];
        }
    }];
}

- (void) notifyGattData:(DPLinkingGattData *)gatt beacon:(DPLinkingBeacon *)beacon {
    [self.gattDataDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconGattDataDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:gattData:)]) {
            [obj didReceivedBeacon:beacon gattData:gatt];
        }
    }];
}

- (void) notifyRawData:(DPLinkingRawData *)rawData beacon:(DPLinkingBeacon *)beacon {
    [self.rawDataDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconRawDataDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:rawData:)]) {
            [obj didReceivedBeacon:beacon rawData:rawData];
        }
    }];
}

- (void) notifyButtonId:(int)buttonId beacon:(DPLinkingBeacon *)beacon {
    [self.buttonIdDelegates enumerateObjectsUsingBlock:^(id<DPLinkingBeaconButtonIdDelegate> obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceivedBeacon:ButtonId:)]) {
            [obj didReceivedBeacon:beacon ButtonId:buttonId];
        }
    }];
}

#pragma mark - BLEConnecterDelegate

- (void) receivedAdvertisement:(CBPeripheral *)peripheral advertisement:(NSDictionary *)data {
    DCLogInfo(@"%@", data);

    long extraId = [[data objectForKey:kIndividualNumber] longValue];
    long vendorId = [[data objectForKey:kHeaderIdentifier] longValue];
    long version = [[data objectForKey:kVersion] longValue];

    DPLinkingBeacon *beacon = [self findBeaconByExtraId:extraId venderId:vendorId];
    if (beacon == nil) {
        beacon = [[DPLinkingBeacon alloc] init];
        beacon.beaconId = [DPLinkingBeacon createIdFromVendorId:vendorId extraId:extraId];
        beacon.displayName = [DPLinkingBeacon createDisplayName:extraId];
        [self.beacons addObject:beacon];
    }
    
    beacon.extraId = extraId;
    beacon.vendorId = vendorId;
    beacon.version = version;
    
    [self parseGattData:beacon advertisement:data];
    [self parseBatteryData:beacon advertisement:data];
    [self parseAtmosphericPressureData:beacon advertisement:data];
    [self parseHumidityData:beacon advertisement:data];
    [self parseTemperatureData:beacon advertisement:data];
    [self parseRawData:beacon advertisement:data];
    [self parseButtonId:beacon advertisement:data];

    if (!beacon.online) {
        beacon.online = YES;
        [self notifyConnectBeacon:beacon];
    }
    
    [self saveDPLinkingBeacon];
    [self notifyBeacon:beacon];
}

@end
