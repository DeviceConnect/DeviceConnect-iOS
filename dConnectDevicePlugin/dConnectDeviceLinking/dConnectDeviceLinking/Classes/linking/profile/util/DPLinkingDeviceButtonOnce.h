//
//  DPLinkingDeviceButtonOnce.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPLinkingTimeoutSchedule.h"
#import "DPLinkingDeviceManager.h"

typedef NS_ENUM(NSInteger, DPLinkingKeyEventType) {
    DPLinkingKeyEventTypeDown = 0,
    DPLinkingKeyEventTypeChange
};

@interface DPLinkingDeviceButtonOnce : DPLinkingTimeoutSchedule <DPLinkingDeviceButtonIdDelegate>

@property (nonatomic) DConnectRequestMessage *request;
@property (nonatomic) DConnectResponseMessage *response;

@property (nonatomic) int type;

- (instancetype) initWithDevice:(DPLinkingDevice *)device;

@end
