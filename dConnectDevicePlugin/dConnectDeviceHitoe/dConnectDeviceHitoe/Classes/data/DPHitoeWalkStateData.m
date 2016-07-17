//
//  DPHitoeWalkStateData.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <DCMDevicePluginSDK/DCMWalkStateProfile.h>
#import "DPHitoeWalkStateData.h"

@implementation DPHitoeWalkStateData
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    [DCMWalkStateProfile setStep:self.step target:message];
    [DCMWalkStateProfile setState:self.state target:message];
    [DCMWalkStateProfile setSpeed:self.speed target:message];
    [DCMWalkStateProfile setDistance:self.distance target:message];
    [DCMWalkStateProfile setBalance:self.balance target:message];
    [DCMWalkStateProfile setTimeStamp:self.timeStamp target:message];
    [DCMWalkStateProfile setTimeStampString:self.timeStampString target:message];
    
    return message;
}
@end
