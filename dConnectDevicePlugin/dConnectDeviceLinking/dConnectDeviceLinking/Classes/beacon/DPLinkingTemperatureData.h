//
//  DPLinkingTemperatureData.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPLinkingTemperatureData : NSObject

@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) float value;
@property (nonatomic) int temperatureType;
@end
