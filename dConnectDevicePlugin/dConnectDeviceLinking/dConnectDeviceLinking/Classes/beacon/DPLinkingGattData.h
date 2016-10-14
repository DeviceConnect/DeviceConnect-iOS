//
//  DPLinkingGattData.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPLinkingGattData : NSObject

@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSNumber *rssi;
@property (nonatomic) float txPower;
@property (nonatomic) float distance;

@end
