//
//  DPLinkingDevice.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPlinkingDevice.h"

static const NSInteger kButton = (1 << 3);

static NSString *const kName = @"name";
static NSString *const kId = @"id";
static NSString *const kLedOffPatternId = @"ledOffPatternId";
static NSString *const kVibrationOffPatternId = @"vibrationOffPatternId";

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
        
        NSLog(@"LDPDevice");
        NSLog(@"    name: %@", self.name);
        NSLog(@"    id: %@", self.identifier);
        NSLog(@"    led: %d", self.ledOffPatternId);
        NSLog(@"    vibration: %d", self.vibrationOffPatternId);
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.identifier forKey:kId];
    [coder encodeObject:@(self.ledOffPatternId) forKey:kLedOffPatternId];
    [coder encodeObject:@(self.vibrationOffPatternId) forKey:kVibrationOffPatternId];
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
    if (!self.setting.exSensorType) {
        return NO;
    }
    
    const unsigned char *ptr = [self.setting.exSensorType bytes];
    unsigned long length = [self.setting.exSensorType length];
    if (!ptr || length <= 0) {
        return NO;
    }
    return (ptr[0] & kButton) != 0;
}

- (BOOL) isSupportBattery {
    // TODO: 未実装
    return NO;
}

- (BOOL) isSupportTemperature {
    // TODO: 未実装
    return NO;
}

- (BOOL) isSupportHumidity {
    // TODO: 未実装
    return NO;
}

@end
