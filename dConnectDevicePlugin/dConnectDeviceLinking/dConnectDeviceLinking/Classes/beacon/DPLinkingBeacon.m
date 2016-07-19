//
//  DPLinkingBeacon.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeacon.h"

static NSString *const kGattDate = @"gatt_date";
static NSString *const kTemperatureDate = @"temp_date";
static NSString *const kHumidityDate = @"humidity_date";
static NSString *const kAtmosphricDate = @"atm_date";
static NSString *const kBatteryDate = @"battery_date";
static NSString *const kRawDate = @"raw_date";
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


@implementation DPLinkingBeacon

- (id) init {
    self = [super init];
    if (self) {
        self.online = NO;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.extraId = [[coder decodeObjectForKey:kIndividualNumber] longValue];
        self.vendorId = [[coder decodeObjectForKey:kHeaderIdentifier] longValue];
        self.version = [[coder decodeObjectForKey:kVersion] longValue];

        self.beaconId = [DPLinkingBeacon createIdFromVendorId:self.vendorId extraId:self.extraId];
        self.displayName = [DPLinkingBeacon createDisplayName:self.extraId];
        
        if ([coder containsValueForKey:kRSSI]) {
            self.gattData = [[DPLinkingGattData alloc] init];
            self.gattData.rssi = [coder decodeObjectForKey:kRSSI];
            self.gattData.txPower = [[coder decodeObjectForKey:kTxPowerLevel] floatValue];
            self.gattData.distance = [[coder decodeObjectForKey:kDistanceInformation] floatValue];
            self.gattData.timeStamp = [[coder decodeObjectForKey:kGattDate] doubleValue];
        }
        
        if ([coder containsValueForKey:kTemperature]) {
            self.temperatureData = [[DPLinkingTemperatureData alloc] init];
            self.temperatureData.value = [[coder decodeObjectForKey:kTemperature] floatValue];
            self.temperatureData.timeStamp = [[coder decodeObjectForKey:kTemperatureDate] doubleValue];
        }
        
        if ([coder containsValueForKey:kHumidity]) {
            self.humidityData = [[DPLinkingHumidityData alloc] init];
            self.humidityData.value = [[coder decodeObjectForKey:kHumidity] floatValue];
            self.humidityData.timeStamp = [[coder decodeObjectForKey:kHumidityDate] doubleValue];
        }
        
        if ([coder containsValueForKey:kAtmosphericPressure]) {
            self.atmosphericPressureData = [[DPLinkingAtmosphericPressureData alloc] init];
            self.atmosphericPressureData.value = [[coder decodeObjectForKey:kAtmosphericPressure] floatValue];
            self.atmosphericPressureData.timeStamp = [[coder decodeObjectForKey:kAtmosphricDate] doubleValue];
        }
        
        if ([coder containsValueForKey:kIsChargingRequired]) {
            self.batteryData = [[DPLinkingBattryData alloc] init];
            self.batteryData.lowBatteryFlag = [[coder decodeObjectForKey:kIsChargingRequired] boolValue];
            self.batteryData.batteryLevel = [[coder decodeObjectForKey:kRemainingPercentage] floatValue];
            self.batteryData.timeStamp = [[coder decodeObjectForKey:kBatteryDate] doubleValue];
        }
        
        if ([coder containsValueForKey:kServiceData]) {
            self.rawData = [[DPLinkingRawData alloc] init];
            self.rawData.value = [[coder decodeObjectForKey:kServiceData] longValue];
            self.rawData.timeStamp = [[coder decodeObjectForKey:kRawDate] doubleValue];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:@(self.extraId) forKey:kIndividualNumber];
    [coder encodeObject:@(self.vendorId) forKey:kHeaderIdentifier];
    [coder encodeObject:@(self.version) forKey:kVersion];

    if (self.gattData) {
        [coder encodeObject:self.gattData.rssi forKey:kRSSI];
        [coder encodeObject:@(self.gattData.txPower) forKey:kTxPowerLevel];
        [coder encodeObject:@(self.gattData.distance) forKey:kDistanceInformation];
        [coder encodeObject:@(self.gattData.timeStamp) forKey:kGattDate];
    }
    
    if (self.temperatureData) {
        [coder encodeObject:@(self.temperatureData.value) forKey:kTemperature];
        [coder encodeObject:@(self.temperatureData.timeStamp) forKey:kTemperatureDate];
    }
    
    if (self.humidityData) {
        [coder encodeObject:@(self.humidityData.value) forKey:kHumidity];
        [coder encodeObject:@(self.humidityData.timeStamp) forKey:kHumidityDate];
    }
    
    if (self.atmosphericPressureData) {
        [coder encodeObject:@(self.atmosphericPressureData.value) forKey:kAtmosphericPressure];
        [coder encodeObject:@(self.atmosphericPressureData.timeStamp) forKey:kAtmosphricDate];
    }
    
    if (self.batteryData) {
        [coder encodeObject:@(self.batteryData.lowBatteryFlag) forKey:kIsChargingRequired];
        [coder encodeObject:@(self.batteryData.batteryLevel) forKey:kRemainingPercentage];
        [coder encodeObject:@(self.batteryData.timeStamp) forKey:kBatteryDate];
    }
    
    if (self.rawData) {
        [coder encodeObject:@(self.rawData.value) forKey:kServiceData];
        [coder encodeObject:@(self.rawData.timeStamp) forKey:kRawDate];
    }
}

- (BOOL)isEqual:(id)object {
    __typeof(self) other = object;
    return self.extraId == other.extraId && self.vendorId == other.vendorId;
}

- (NSUInteger)hash {
    NSString *str = [NSString stringWithFormat:@"%@_%@", @(self.vendorId), @(self.extraId)];
    return str.hash;
}

+ (NSString *) createDisplayName:(long)extraId
{
    return [NSString stringWithFormat:@"Linking:ビーコン(%ld)", extraId];
}

+ (NSString *) createIdFromVendorId:(long)vendorId extraId:(long)extraId
{
    return [NSString stringWithFormat:@"%@_%@", @(vendorId), @(extraId)];
}

@end
