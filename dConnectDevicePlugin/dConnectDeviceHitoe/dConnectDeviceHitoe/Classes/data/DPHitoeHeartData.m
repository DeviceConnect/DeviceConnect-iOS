//
//  DPHitoeHeartData.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <DCMDevicePluginSDK/DCMHealthProfile.h>
#import "DPHitoeHeartData.h"

@implementation DPHitoeHeartData


- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    [DCMHealthProfile setValue:self.value target:message];
    [DCMHealthProfile setMDERFloat:self.mderFloat target:message];
    [DCMHealthProfile setType:self.type target:message];
    [DCMHealthProfile setTypeCode:self.typeCode target:message];
    [DCMHealthProfile setUnit:self.unit target:message];
    [DCMHealthProfile setUnitCode:self.unitCode target:message];
    [DCMHealthProfile setTimeStamp:self.timeStamp target:message];
    [DCMHealthProfile setTimeStampString:self.timeStampString target:message];
    return message;
}
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
@end
