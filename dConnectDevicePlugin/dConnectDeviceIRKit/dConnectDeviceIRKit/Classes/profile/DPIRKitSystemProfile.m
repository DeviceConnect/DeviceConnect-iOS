//
//  DPIRKitSystemProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitSystemProfile.h"
#import "DPIRKitDevicePlugin.h"
#import <DConnectSDK/DConnectEventManager.h>

@implementation DPIRKitSystemProfile

- (id)initWithDelegate: (id<DConnectSystemProfileDelegate>) delegate dataSource: (id<DConnectSystemProfileDataSource>) dataSource {
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.dataSource = dataSource;
        __weak DPIRKitSystemProfile *weakSelf = self;
        
        // API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         
                         BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
                         return send;
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *origin = [request origin];
                            
                            DConnectEventManager *eventMgr = [DConnectEventManager sharedManagerForClass:[DPIRKitDevicePlugin class]];
                            if ([eventMgr removeEventsForOrigin:origin]) {
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

@end
