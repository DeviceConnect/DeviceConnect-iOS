//
//  DPLinkingDevice.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <LinkingLibrary/LinkingLibrary.h>

typedef NS_ENUM(NSInteger, DPLinkingSensorStatus) {
    DPLinkingSensorStatusStop = 0,
    DPLinkingSensorStatusStart
};

typedef NS_ENUM(NSInteger, DPLinkingSettingNameType) {
    DPLinkingSettingNameTypeLEDColorName = 0,
    DPLinkingSettingNameTypeLEDPatternName,
    DPLinkingSettingNameTypeVibrationPatternName
};

typedef NS_ENUM(NSInteger, DPLinkingRange) {
    DPLinkingRangeImmediate = 0,
    DPLinkingRangeNear,
    DPLinkingRangeFar
};

typedef NS_ENUM(NSInteger, DPLinkingResultCode) {
    DPLinkingResultCodeOk = 0,
    DPLinkingResultCodeCancel,
    DPLinkingResultCodeError,
    DPLinkingResultCodeErrorNoReason,
    DPLinkingResultCodeErrorNotAvailable,
    DPLinkingResultCodeErrorNotSupport
};

@interface DPLinkingDevice : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identifier;
@property (nonatomic) int ledOffPatternId;
@property (nonatomic) int vibrationOffPatternId;
@property (nonatomic) BOOL connectFlag;

@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BLEDeviceSetting *setting;
@property (nonatomic) BOOL online;

- (BOOL) isSupportLED;
- (BOOL) isSupportVibration;
- (BOOL) isSupportGryo;
- (BOOL) isSupportAcceleration;
- (BOOL) isSupportCompass;
- (BOOL) isSupportSensor;
- (BOOL) isSupportButtonId;
- (BOOL) isSupportBattery;
- (BOOL) isSupportTemperature;
- (BOOL) isSupportHumidity;
- (BOOL) isSupportAtmosphericPressure;
- (BOOL) isInDistanceThreshold;

@end
