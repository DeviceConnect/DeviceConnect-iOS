//
//  DPHitoePoseEstimationData.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DCMDevicePluginSDK/DCMPoseEstimationProfile.h>
#import "DPHitoePoseEstimationData.h"

@implementation DPHitoePoseEstimationData
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}

- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    [DCMPoseEstimationProfile setState:self.state target:message];
    [DCMPoseEstimationProfile setTimeStamp:self.timeStamp target:message];
    [DCMPoseEstimationProfile setTimeStampString:self.timeStampString target:message];
    
    return message;
}

@end
