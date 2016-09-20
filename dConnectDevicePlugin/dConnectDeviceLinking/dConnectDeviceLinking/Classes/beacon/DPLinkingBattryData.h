//
//  DPLinkingBattryData.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPLinkingBattryData : NSObject

@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) BOOL lowBatteryFlag;
@property (nonatomic) float batteryLevel;

@end
