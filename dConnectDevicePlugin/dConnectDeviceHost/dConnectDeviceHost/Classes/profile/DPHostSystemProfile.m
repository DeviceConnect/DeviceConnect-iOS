//
//  DPHostSystemProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPHostDevicePlugin.h"
#import "DPHostSystemProfile.h"

@interface DPHostSystemProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@end

@implementation DPHostSystemProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        __weak DPHostSystemProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        
        // API登録(settingPageForRequest相当)
        NSString *putSettingPageForRequestApiPath = [self apiPathWithProfile: self.profileName
                                                               interfaceName: DConnectSystemProfileInterfaceDevice
                                                               attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
                         return send;
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPathWithProfile: self.profileName
                                                          interfaceName: nil
                                                          attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *sessionKey = [request sessionKey];
                         
                         if ([[weakSelf eventMgr] removeEventsForSessionKey:sessionKey]) {
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToUnknownWithMessage:
                              @"Failed to remove events associated with the specified session key."];
                         }
                         
                         return YES;
                     }];

    }
    return self;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"2.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    // 設定画面無し；nilを返す。
    return nil;
}

@end
