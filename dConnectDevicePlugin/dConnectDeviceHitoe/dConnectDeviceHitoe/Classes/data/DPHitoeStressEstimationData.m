//
//  DPHitoeStressEstimationData.m
//  dConnectDeviceHitoe
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DCMDevicePluginSDK/DCMStressEstimationProfile.h>
#import "DPHitoeStressEstimationData.h"

@implementation DPHitoeStressEstimationData
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    [DCMStressEstimationProfile setLFHF:self.lfhf target:message];
    [DCMStressEstimationProfile setTimeStamp:self.timeStamp target:message];
    [DCMStressEstimationProfile setTimeStampString:self.timeStampString target:message];
    
    return message;
}
@end
