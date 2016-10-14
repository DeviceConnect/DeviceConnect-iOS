//
//  DConnectManagerServiceDiscoveryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManagerServiceDiscoveryProfile.h"
#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import "DConnectManager+Private.h"
#import "DConnectEventManager.h"
#import "DConnectService.h"

/** NetworkDiscoveryのタイムアウト. */
#define DISCOVERY_TIMEOUT 8

@implementation DConnectManagerServiceDiscoveryProfile

- (id) init {
    
    self = [super initWithServiceProvider: nil];
    if (self) {
        __weak DConnectManagerServiceDiscoveryProfile *weakSelf = self;

        NSString *getServicesRequestApiPath = [self apiPath: nil
                                              attributeName: nil];
        [self addGetPath: getServicesRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf getServicesRequest: request response: response];
                     }];
        
        NSString *putOnServiceChangeRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectServiceDiscoveryProfileAttrOnServiceChange];
        [self addPutPath: putOnServiceChangeRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DConnectManager class]];
                         
                         DConnectEventError error = [mgr addEventForRequest:request];
                         switch (error) {
                             case DConnectEventErrorNone:
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter:
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorFailed:
                             default:
                                 [response setErrorToUnknown];
                                 break;
                         }
                         return YES;
                     }];
        
        NSString *deleteOnServiceChangeRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectServiceDiscoveryProfileAttrOnServiceChange];
        [self addDeletePath: deleteOnServiceChangeRequestApiPath
                        api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DConnectManager class]];
                            
                            DConnectEventError error = [mgr removeEventForRequest:request];
                            switch (error) {
                                case DConnectEventErrorNone:
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter:
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:
                                    [response setErrorToInvalidRequestParameterWithMessage:@"event does not exist."];
                                    break;
                                case DConnectEventErrorFailed:
                                default:
                                    [response setErrorToUnknown];
                                    break;
                            }
                            return YES;
                     }];
    }

    return self;
}

- (BOOL)getServicesRequest : (DConnectRequestMessage *) request response: (DConnectResponseMessage *) response {
    
    // GotAPI対応: プラグイン側のI/Fに変換
    //    GET /servicediscovery -> GET /networkServiceDiscovery/getNetworkServices
    [request setProfile:DConnectProfileNameNetworkServiceDiscovery];
    [request setAttribute:DConnectAttributeNameGetNetworkServices];
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * DISCOVERY_TIMEOUT);
    DConnectArray *services = [DConnectArray array];
    
    // 各デバイスプラグインからのレスポンスを受け取る
    DConnectManager *mgr = [DConnectManager sharedManager];
    DConnectDevicePluginManager *deviceMgr = mgr.mDeviceManager;
    NSArray *devices = [deviceMgr devicePluginList];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t discoveryGroup = dispatch_group_create();
    
    NSMutableArray *callbackCodes = [NSMutableArray array];
    
    for (DConnectDevicePlugin *plugin in devices) {
        DConnectResponseMessage *resp = [DConnectResponseMessage message];
        [callbackCodes addObject:resp.code];
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [mgr addCallback:^(DConnectResponseMessage *response) {
            
            int result = [response integerForKey:DConnectMessageResult];
            if (result == DConnectMessageResultTypeOk) {
                DConnectArray *foundServices = [resp arrayForKey:DConnectServiceDiscoveryProfileParamServices];
                if ([foundServices count] > 0) {
                    for (int i = 0; i < [foundServices count]; i++) {
                        DConnectMessage *msg = [foundServices messageAtIndex:i];
                        NSString *serviceId = [msg stringForKey:DConnectServiceDiscoveryProfileParamId];
                        if (serviceId) {
                            // サービスIDにデバイスプラグインのIDを付加する
                            NSString *did = [deviceMgr serviceIdByAppedingPluginIdWithDevicePlugin:plugin
                                                                                         serviceId:serviceId];
                            [msg setString:did forKey:DConnectServiceDiscoveryProfileParamId];
                            DConnectArray *profile = [DConnectArray new];
                            for (DConnectService *service in plugin.serviceProvider.services) {
                                for (DConnectProfile *p in service.profiles) {
                                    [profile addString:p.profileName];
                                }
                            }
                            [msg setArray:profile forKey:DConnectServiceDiscoveryProfileParamScopes];
                            @synchronized (services) {
                                [services addMessage:msg];
                            }
                        }
#ifdef DEBUG
                        else {
                            DCLogW(@"Not found id. %@", NSStringFromClass([plugin class]));
                        }
#endif
                    }
                }
            }
            dispatch_semaphore_signal(sem);
        } forKey:resp.code];
        
        dispatch_group_async(discoveryGroup, queue, ^{
            BOOL send = [plugin didReceiveRequest:request response:resp];
            if (send) {
                [mgr sendResponse:resp];
            }
            dispatch_semaphore_wait(sem, timeout);
        });
    }
    
    long result = dispatch_group_wait(discoveryGroup, timeout);
    
    DConnectArray *responseServices = nil;
    if (result != 0) {
        @synchronized (services) {
            // タイムアウトした場合はあとから
            // 処理されたものが追加されないようにコピーにしておく。
            responseServices = [services copy];
        }
        
        // ゴミが残ってしまうのでタイムアウトしたらコールバックを解除しておく
        for (NSString *code in callbackCodes) {
            [mgr removeCallbackForKey:code];
        }
    } else {
        responseServices = services;
    }
    
    // レスポンスを作成
    [response setResult:DConnectMessageResultTypeOk];
    [DConnectServiceDiscoveryProfile setServices:responseServices target:response];
    
    return YES;
}



#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectServiceDiscoveryProfileName;
}
@end
