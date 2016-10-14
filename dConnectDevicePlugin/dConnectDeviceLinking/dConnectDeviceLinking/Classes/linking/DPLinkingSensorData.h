//
//  DPLinkingSensorData.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DPLinkingSensorType) {
    DPLinkingSensorTypeGyroscope = 0,
    DPLinkingSensorTypeAccelerometer = 0x01,
    DPLinkingSensorTypeOrientation = 0x02,
    DPLinkingSensorTypeBattery = 0x03,
    DPLinkingSensorTypeTemperature = 0x04,
    DPLinkingSensorTypeHumidity = 0x05,
    DPLinkingSensorTypeAtmosphericPressure = 0x06
};

@interface DPLinkingSensorData : NSObject

@property (nonatomic) DPLinkingSensorType type;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;
@property (nonatomic) NSData *originalData;
@property (nonatomic) NSTimeInterval timeStamp;

@end
