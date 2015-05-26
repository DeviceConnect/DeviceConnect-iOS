//
//  DPHostProximityProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostDevicePlugin.h"
#import "DPHostProximityProfile.h"
#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostUtils.h"

typedef void (^DPHostProximityBlock)(DConnectMessage *);

@interface DPHostProximityProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@property id proximityBlock;
@property id onceProximityBlock;
@property BOOL proximityState;

- (void) sendOnUserProximityEvent:(NSNotification *)notification;

@end

@implementation DPHostProximityProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        
        if (![UIDevice currentDevice].proximityMonitoringEnabled) {
            // YESを設定したのにNOのまま；近接センサーがサポートされてないので、
            // そもそもプロファイルをインスタンス化させないでDevice System APIにProximity
            // プロファイルが表示されない様にする。
            return nil;
        }
        
        // YESを設定してYES；近接センサーがサポートされている。
        self.delegate = self;
        self.proximityBlock = nil;
        self.onceProximityBlock = nil;
        self.proximityState = NO;
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                     selector:@selector(sendOnUserProximityEvent:)
                                                         name:UIDeviceProximityStateDidChangeNotification
                                                       object:nil];
        });

    }
    return self;
}

- (void)dealloc
{
    // 通知の受領をやめる。
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) hasUserProximityEventList:(NSString *)serviceId
{
    NSArray *evts = [_eventMgr eventListForServiceId:serviceId
                                             profile:DConnectProximityProfileName
                                           attribute:DConnectProximityProfileAttrOnUserProximity];
    return evts && evts.count > 0;
}

- (void) sendOnUserProximityEvent:(NSNotification *)notification
{
    DConnectMessage *proximity = [DConnectMessage message];
    self.proximityState = [notification.object proximityState];
    [DConnectProximityProfile setNear:[notification.object proximityState] target:proximity];

    if (self.proximityBlock) {
        DPHostProximityBlock block = self.proximityBlock;
        block(proximity);
    }
    
}

#pragma mark - Get Methods

- (BOOL)                    profile:(DConnectProximityProfile *)profile
didReceiveGetOnUserProximityRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
{
    DConnectMessage *proximity = [DConnectMessage message];
    [response setResult:DConnectMessageResultTypeOk];

    [DConnectProximityProfile setNear:self.proximityState target:proximity];
    [DConnectProximityProfile setProximity:proximity target:response];

    return YES;
}

#pragma mark - Put Methods
#pragma mark Event Regstration

- (BOOL)                    profile:(DConnectProximityProfile *)profile
didReceivePutOnUserProximityRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    __unsafe_unretained typeof(self) weakSelf = self;

    NSArray *evts = [_eventMgr eventListForServiceId:serviceId
                                            profile:DConnectProximityProfileName
                                          attribute:DConnectProximityProfileAttrOnUserProximity];
    if (evts.count == 0) {
        self.proximityBlock = ^(DConnectMessage *message) {
            // イベントの取得
            NSArray *evts = [weakSelf.eventMgr eventListForServiceId:ServiceDiscoveryServiceId
                                                             profile:DConnectProximityProfileName
                                                           attribute:DConnectProximityProfileAttrOnUserProximity];
            
            DPHostDevicePlugin *plugin = (DPHostDevicePlugin *)weakSelf.provider;
            // イベント送信
            for (DConnectEvent *evt in evts) {
                DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
                [DConnectProximityProfile setProximity:message target:eventMsg];
                [plugin sendEvent:eventMsg];
            }
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;

            [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                     selector:@selector(sendOnUserProximityEvent:)
                                                         name:UIDeviceProximityStateDidChangeNotification
                                                       object:nil];
        });
    }
    
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // エラー無し.
            [response setResult:DConnectMessageResultTypeOk];
            break;
        case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
            [response setErrorToInvalidRequestParameter];
            break;
        case DConnectEventErrorNotFound:         // マッチするイベント無し.
        case DConnectEventErrorFailed:           // 処理失敗.
            [response setErrorToUnknown];
            break;
    }
    
    return YES;
}

#pragma mark - Delete Methods
#pragma mark Event Unregstration

- (BOOL)                       profile:(DConnectProximityProfile *)profile
didReceiveDeleteOnUserProximityRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // エラー無し.
            [response setResult:DConnectMessageResultTypeOk];
            break;
        case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
            [response setErrorToInvalidRequestParameter];
            break;
        case DConnectEventErrorNotFound:         // マッチするイベント無し.
        case DConnectEventErrorFailed:           // 処理失敗.
            [response setErrorToUnknown];
            break;
    }
    
    NSArray *evts = [_eventMgr eventListForServiceId:serviceId
                                            profile:DConnectProximityProfileName
                                          attribute:DConnectProximityProfileAttrOnUserProximity];
    if (evts.count == 0) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceProximityStateDidChangeNotification
                                                      object:nil];
        self.proximityBlock = nil;
    }
    
    return YES;
}

@end
