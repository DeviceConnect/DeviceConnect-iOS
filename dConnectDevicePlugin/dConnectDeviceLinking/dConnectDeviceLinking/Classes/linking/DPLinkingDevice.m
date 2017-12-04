//
//  DPLinkingDevice.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDevice.h"
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>


static NSString *const kName = @"name";
static NSString *const kId = @"id";
static NSString *const kLedOffPatternId = @"ledOffPatternId";
static NSString *const kVibrationOffPatternId = @"vibrationOffPatternId";
static NSString *const kConnectFlag = @"connectFlag";

@implementation DPLinkingDevice

- (id) init {
    self = [super init];
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:kName];
        self.identifier = [coder decodeObjectForKey:kId];
        self.ledOffPatternId = [[coder decodeObjectForKey:kLedOffPatternId] intValue];
        self.vibrationOffPatternId = [[coder decodeObjectForKey:kVibrationOffPatternId] intValue];
        self.connectFlag = [[coder decodeObjectForKey:kConnectFlag] boolValue];
        self.temperatureType = DCMTemperatureProfileEnumCelsius;
        self.online = NO;

        DCLogInfo(@"LDPDevice");
        DCLogInfo(@"    name: %@", self.name);
        DCLogInfo(@"    id: %@", self.identifier);
        DCLogInfo(@"    led: %d", self.ledOffPatternId);
        DCLogInfo(@"    vibration: %d", self.vibrationOffPatternId);
        DCLogInfo(@"    connectFlag: %@", self.connectFlag ? @"YES" : @"NO");
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.identifier forKey:kId];
    [coder encodeObject:@(self.ledOffPatternId) forKey:kLedOffPatternId];
    [coder encodeObject:@(self.vibrationOffPatternId) forKey:kVibrationOffPatternId];
    [coder encodeObject:@(self.connectFlag) forKey:kConnectFlag];
}

- (BOOL) isSupportLED {
    return self.setting.lEDColorName != nil && self.setting.lEDColorName.count > 0
            && self.setting.lEDPatternName != nil && self.setting.lEDPatternName.count > 0;
}

- (BOOL) isSupportVibration {
    return self.setting.vibrationPatternName != nil && self.setting.vibrationPatternName.count > 0
            && self.setting.vibrationPatternArray != nil && self.setting.vibrationPatternArray.count > 0;
}

- (BOOL) isSupportGryo {
    return self.setting.hasGyroscope;
}

- (BOOL) isSupportAcceleration {
    return self.setting.hasAccelerometer;
}

- (BOOL) isSupportCompass {
    return self.setting.hasOrientation;
}

- (BOOL) isSupportSensor {
    return self.setting.hasOrientation || self.setting.hasGyroscope || self.setting.hasAccelerometer;
}

- (BOOL) isSupportButtonId {
    return self.setting.hasExButton;
}

- (BOOL) isSupportBattery {
    return self.setting.hasBatteryPower;
}

- (BOOL) isSupportTemperature {
    return self.setting.hasTemperature;
}

- (BOOL) isSupportHumidity {
    return self.setting.hasHumidity;
}

- (BOOL) isSupportAtmosphericPressure {
    return self.setting.hasAtmosphericPressure;
}

- (BOOL) isInDistanceThreshold {
    return self.setting.isInDistanceThreshold;
}

@end
