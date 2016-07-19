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
    DPLinkingSensorTypeAccelerometer,
    DPLinkingSensorTypeOrientation,
    DPLinkingSensorTypeBattery,
    DPLinkingSensorTypeTemperature,
    DPLinkingSensorTypeHumidity
};

@interface DPLinkingSensorData : NSObject

@property (nonatomic) DPLinkingSensorType type;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;
@property (nonatomic) NSData *originalData;
@property (nonatomic) NSTimeInterval timeStamp;

@end
