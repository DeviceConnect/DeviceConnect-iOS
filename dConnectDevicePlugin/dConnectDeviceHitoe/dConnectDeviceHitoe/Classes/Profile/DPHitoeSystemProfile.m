//
//  DPHitoeSystemProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPHitoeDevicePlugin.h"
#import "DPHitoeSystemProfile.h"
#import "DPHitoeConsts.h"

@interface DPHitoeSystemProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@end

@implementation DPHitoeSystemProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataSource = self;
        __weak DPHitoeSystemProfile *weakSelf = self;

        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        // API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         return [weakSelf didReceivePutWakeupRequest:request response:response];
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *sessionKey = [request sessionKey];
                            
                            return [weakSelf didReceiveDeleteEventsRequest:request response:response sessionKey:sessionKey];
                        }];

    }
    return self;
}

#pragma mark - DConnectSystemProfileDelegate


#pragma mark - Delete Methods

- (BOOL)
didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                   sessionKey:(NSString *)sessionKey
{
    if ([_eventMgr removeEventsForSessionKey:sessionKey]) {
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToUnknownWithMessage:
         @"Failed to remove events associated with the specified session key."];
    }
    
    return YES;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"1.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    NSBundle *bundle = DPHitoeBundle();
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Hitoe_iPhone" bundle:bundle];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:@"Hitoe_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
}

@end
