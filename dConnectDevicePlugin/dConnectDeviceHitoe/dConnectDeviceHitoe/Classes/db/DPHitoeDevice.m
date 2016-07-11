//
//  DPHitoeDevice.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDevice.h"

@implementation DPHitoeDevice

- (id) init {
    if (self = [super init]) {
        self.availableBaDataList = [NSMutableArray array];
        self.availableExDataList = [NSMutableArray array];
        self.availableRawDataList = [NSMutableArray array];
        self.exConnectionList = [NSMutableArray array];
    }
    return self;
}
@end
