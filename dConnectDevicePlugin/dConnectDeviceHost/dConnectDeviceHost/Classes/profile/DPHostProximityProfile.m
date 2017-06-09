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
#import "DPHostService.h"
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
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;

        // YESを設定してYES；近接センサーがサポートされている。
        __weak DPHostProximityProfile *weakSelf = self;
        self.proximityBlock = nil;
        self.onceProximityBlock = nil;
        self.proximityState = NO;
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];


        // API登録(didReceiveGetOnUserProximityRequest相当)
        NSString *getOnUserProximityRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addGetPath: getOnUserProximityRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [UIDevice currentDevice].proximityMonitoringEnabled = YES;
                              [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                                       selector:@selector(sendOnUserProximityEvent:)
                                                                           name:UIDeviceProximityStateDidChangeNotification
                                                                         object:nil];
                          });
                          dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                          DConnectMessage *proximity = [DConnectMessage message];

                          [response setResult:DConnectMessageResultTypeOk];
                          [DConnectProximityProfile setNear:NO target:proximity];
                          [DConnectProximityProfile setProximity:proximity target:response];

                          weakSelf.onceProximityBlock = ^(DConnectMessage *message) {
                              [response setResult:DConnectMessageResultTypeOk];
                              [DConnectProximityProfile setProximity:message target:response];
                              dispatch_semaphore_signal(semaphore);
                          };
                          dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
                          NSString *serviceId = [request serviceId];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              NSArray *evts = [[weakSelf eventMgr] eventListForServiceId:serviceId
                                                                                 profile:DConnectProximityProfileName
                                                                               attribute:DConnectProximityProfileAttrOnUserProximity];
                              if (evts.count == 0) {
                                  [UIDevice currentDevice].proximityMonitoringEnabled = NO;
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:weakSelf
                                                                                  name:UIDeviceProximityStateDidChangeNotification
                                                                                object:nil];
                                  weakSelf.onceProximityBlock = nil;
                              }
                          });
                          
                          return YES;
                      }];

        // API登録(didReceivePutOnUserProximityRequest相当)
        NSString *putOnUserProximityRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addPutPath: putOnUserProximityRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         NSArray *evts = [[weakSelf eventMgr] eventListForServiceId:serviceId
                                                                  profile:DConnectProximityProfileName
                                                                attribute:DConnectProximityProfileAttrOnUserProximity];
                         if (evts.count == 0) {
                             weakSelf.proximityBlock = ^(DConnectMessage *message) {
                                 // イベントの取得
                                 NSArray *evts = [weakSelf.eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                                                                  profile:DConnectProximityProfileName
                                                                                attribute:DConnectProximityProfileAttrOnUserProximity];
                                 
                                 DPHostDevicePlugin *plugin = (DPHostDevicePlugin *)weakSelf.plugin;
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
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
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
                     }];

        // API登録(didReceiveDeleteOnUserProximityRequest相当)
        NSString *deleteOnUserProximityRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addDeletePath: deleteOnUserProximityRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                            NSString *serviceId = [request serviceId];
                            
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
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
                            
                            NSArray *evts = [[weakSelf eventMgr] eventListForServiceId:serviceId
                                                                     profile:DConnectProximityProfileName
                                                                   attribute:DConnectProximityProfileAttrOnUserProximity];
                            if (evts.count == 0) {
                                [UIDevice currentDevice].proximityMonitoringEnabled = NO;
                                
                                [[NSNotificationCenter defaultCenter] removeObserver:weakSelf
                                                                                name:UIDeviceProximityStateDidChangeNotification
                                                                              object:nil];
                                weakSelf.proximityBlock = nil;
                            }
                            
                            return YES;
                        }];


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
    if (self.onceProximityBlock) {
        DPHostProximityBlock block = self.onceProximityBlock;
        block(proximity);
    }
}

@end
