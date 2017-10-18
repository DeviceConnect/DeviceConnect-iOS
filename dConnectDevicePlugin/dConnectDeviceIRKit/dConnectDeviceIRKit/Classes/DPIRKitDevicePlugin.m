//
//  DPIRKitDevicePlugin.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitDevicePlugin.h"
#import "DPIRKit_irkit.h"
#import "DPIRKitRemoteControllerProfile.h"
#import "DPIRKitConst.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitRESTfulRequest.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitSystemProfile.h"
#import "DPIRKitService.h"
#import "DPIRKitReachability.h"
#import <DConnectSDK/DConnectServiceListViewController.h>
#import "DPIRKitVirtualDeviceViewController.h"
#import "DPIRKitVirtualService.h"

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

#define DCPutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

NSString *const DPIRKitInfoVersion = @"DPIRKitVersion";
NSString *const DPIRKitInfoAPIKey = @"DPIRKitAPIKey";
NSString *const DPIRKitStoryBoardName = @"Storyboard_";
NSString *const DPIRKitPluginName = @"IRKit (Device Connect Device Plug-in)";

// Const.h
NSString *const DPIRKitBundleName = @"dConnectDeviceIRKit_resources";
NSString *const DPIRKitInfoPlistName = @"dConnectDeviceIRKit-Info";

@interface DPIRKitDevicePlugin()
<
// プロファイルデリゲート
DConnectServiceInformationProfileDataSource,
DConnectSystemProfileDelegate,
DConnectSystemProfileDataSource,

// デバイス検知デリゲート
DPIRKitManagerDetectionDelegate
>

{
    NSMutableDictionary *_devices;
    DConnectEventManager *_eventManager;
    NSString *_version;
}

@property (nonatomic, strong) DPIRKitReachability *reachability;

- (void) sendDeviceDetectionEventWithDevice:(DPIRKitDevice *)device online:(BOOL)online;

- (void) startObeservation;
- (void) stopObeservation;

@end

@implementation DPIRKitDevicePlugin

#pragma mark - Initializaion

- (id) init {
    
    self = [super initWithObject: self];
    
    if (self) {
        
        DPIRKitManager *manager = [DPIRKitManager sharedInstance];
        [manager setServiceProvider: self.serviceProvider];
        [manager setPlugin:self];
        
        // System Profileの追加
        [self addProfile:[[DPIRKitSystemProfile alloc] initWithDelegate:self dataSource:self]];
        
        _devices = [NSMutableDictionary dictionary];
        id<DConnectEventCacheController> controller = [[DConnectMemoryCacheController alloc] init];
        _eventManager = [DConnectEventManager sharedManagerForClass:[DPIRKitDevicePlugin class]];
        [_eventManager setController:controller];
        NSString* path = [DPIRBundle() pathForResource:DPIRKitInfoPlistName ofType:@"plist"];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
//        _version = info[DPIRKitInfoVersion];
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            [notificationCenter addObserver:_self selector:@selector(startObeservation)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
            [notificationCenter addObserver:_self selector:@selector(stopObeservation)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:application];
            
            manager.apiKey = info[DPIRKitInfoAPIKey];
            manager.detectionDelegate = _self;
            
            [_self startObeservation];
        });
        self.pluginName = DPIRKitPluginName;
        
        // Reachabilityの初期処理
        self.reachability = [DPIRKitReachability reachabilityWithHostName: @"www.google.com"];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(notifiedNetworkStatus:)
         name:DPIRKitReachabilityChangedNotification
         object:nil];
        [self.reachability startNotifier];
    }
    
    return self;
}

- (void) dealloc {
    _devices = nil;
    _eventManager = nil;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
    
    [self stopObeservation];
}

#pragma mark - Public Methods

- (DPIRKitDevice *) deviceForServiceId:(NSString *)serviceId {
    @synchronized (_devices) {
        return _devices[serviceId];
    }
}

- (BOOL)sendTVIRRequestWithServiceId:(NSString *)serviceId
                              method:(NSString *)method
                                 uri:(NSString *)uri
                            response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                  profile:@"/tv"];
    if (requests.count == 0) {
        [response setErrorToNotSupportProfile];
        return send;
    }
    DPIRKitRESTfulRequest *sendReq = nil;
    for (DPIRKitRESTfulRequest *req in requests) {
        if ([req.uri isEqualToString:uri] && [req.method isEqualToString:method] && req.ir) {
            sendReq = req;
            break;
        }
    }
    if (sendReq) {
        send = [self sendIRWithServiceId:serviceId message:sendReq.ir response:response];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"IR is not registered for that request"];
    }
    
    return send;
}

- (BOOL)sendIRWithServiceId:(NSString *)serviceId
                    message:(NSString *)message
                   response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *ids = [serviceId componentsSeparatedByString:@"."];
    DPIRKitDevice *device = [[DPIRKitManager sharedInstance] deviceForServiceId:ids[0]];
    if (message) {
        NSData *jsonData = [message dataUsingEncoding:NSUnicodeStringEncoding];
        id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:NULL];
        if (![NSJSONSerialization isValidJSONObject:jsonObj]) {
            [response setErrorToInvalidRequestParameter];
            return send;
        }
    }
    if (!message) {
        [response setErrorToInvalidRequestParameter];
    } else {
        send = NO;
        [[DPIRKitManager sharedInstance] sendMessage:message withHostName:device.hostName completion:^(BOOL success) {
            if (success) {
                response.result = DConnectMessageResultTypeOk;
            } else {
                [response setErrorToUnknown];
            }
            
            [[DConnectManager sharedManager] sendResponse:response];
        }];
    }
    return send;
}

#pragma mark - Private Methods

- (void) sendDeviceDetectionEventWithDevice:(DPIRKitDevice *)device online:(BOOL)online {
    BOOL hit = NO;
    @synchronized (_devices) {
        
        DPIRKitDevice *irkit = _devices[device.name];
        
        if (irkit) {
            hit = YES;
            if (!online) {
                [_devices removeObjectForKey:device.name];
            }
        } else if (online) {
            _devices[device.name] = device;
        }
    }
    if ((!hit && online) || (hit && !online)) {
        
        if (self.serviceProvider) {
            if (online) {
                // オンライン遷移の場合、デバイスが未登録なら登録し、登録済ならフラグをオンラインにする
                NSString *serviceId = device.name;
                if ([self.serviceProvider service: serviceId]) {
                    DConnectService *service = [self.serviceProvider service: serviceId];
                    [service setOnline: YES];
                } else {
                    DPIRKitService *service = [[DPIRKitService alloc] initWithServiceId: serviceId plugin: self];
                    [self.serviceProvider addService: service bundle: DPIRBundle()];
                    [service setOnline: YES];
                }
            } else {
                // オフライン遷移の場合、デバイスが登録済ならフラグをオフラインにする
                NSString *serviceId = device.name;
                DConnectService *service = [self.serviceProvider service: serviceId];
                if (service) {
                    [service setOnline: NO];
                }
            }
            
            //仮想デバイスの追加
            NSArray *virtuals = [[DPIRKitDBManager sharedInstance] queryVirtualDevice:nil];
            if (virtuals.count > 0) {
                for (DPIRKitVirtualDevice *virtual in virtuals) {
                    NSRange range = [virtual.serviceId rangeOfString:device.name];
                    if (range.location != NSNotFound) {
                        
                        if ([self existIRForServiceId:virtual.serviceId]) {
                            // オンライン遷移の場合、デバイスが未登録なら登録し、登録済ならフラグをオンラインにする
                            NSString *serviceId = virtual.serviceId;
                            if ([self.serviceProvider service: serviceId]) {
                                DConnectService *service = [self.serviceProvider service: serviceId];
                                [service setOnline: online];
                            } else {
                                DPIRKitVirtualService *service = [[DPIRKitVirtualService alloc] initWithServiceId: serviceId
                                                                                                             name:virtual.deviceName
                                                                                                           plugin:self
                                                                                                      profileName:virtual.categoryName];
                                [service setOnline: online];
                                [self.serviceProvider addService: service bundle: DPIRBundle()];

                            }
                        } else {
                            // オフライン遷移の場合、デバイスが登録済ならフラグをオフラインにする
                            NSString *serviceId = virtual.serviceId;
                            DConnectService *service = [self.serviceProvider service: serviceId];
                            if (service) {
                                [service setOnline: NO];
                                [self.serviceProvider addService: service bundle: DPIRBundle()];
                            } else {
                                service = [[DPIRKitVirtualService alloc] initWithServiceId: serviceId
                                                                                      name:virtual.deviceName
                                                                                    plugin:self
                                                                               profileName:virtual.categoryName];
                                [service setOnline: NO];
                                [self.serviceProvider addService: service bundle: DPIRBundle()];
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        NSArray *events = [_eventManager eventListForProfile:DConnectServiceDiscoveryProfileName
                                                   attribute:DConnectServiceDiscoveryProfileAttrOnServiceChange];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *message = [DConnectMessage message];
            [message setString:@"" forKey:DConnectMessageServiceId];
            [message setString:DConnectServiceDiscoveryProfileName forKey:DConnectMessageProfile];
            [message setString:DConnectServiceDiscoveryProfileAttrOnServiceChange forKey:DConnectMessageAttribute];
            [message setString:event.origin forKey:DConnectMessageOrigin];
            [self sendEvent:message];
        }
    }
}

- (void) startObeservation {
    
    @synchronized (_devices) {
        [_devices removeAllObjects];
    }
    
    [[DPIRKitManager sharedInstance] startDetection];
}

- (void) stopObeservation {
    [[DPIRKitManager sharedInstance] stopDetection];
}

// 一つでも赤外線が登録されているかをチェックする
- (BOOL) existIRForServiceId:(NSString *)serviceId {
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                  profile:nil];
    for (DPIRKitRESTfulRequest *request in requests) {
        DPIRLog(@"%@:%@", request.name,request.ir);
        NSRange range = [request.ir rangeOfString:@"{\"format\":\"raw\","];
        if (request.ir && range.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Profile Delegate

#pragma mark DConnectSystemProfileDataSource

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyBoard;
    storyBoard = [UIStoryboard storyboardWithName:@"DConnectSDK-iPhone"
                                           bundle:DCBundle()];
    UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"ServiceList"];
    DConnectServiceListViewController *serviceListViewController = (DConnectServiceListViewController *) top.viewControllers[0];
    serviceListViewController.delegate = self;
    return top;
}
- (void)didRemovedService:(DConnectService *)service
{
    // IRKitのServiceIdに.がある場合は仮想デバイスとみなす
    NSRange range = [service.serviceId rangeOfString:@"."];
    if (range.location != NSNotFound) {
        //サービス一覧画面で仮想デバイスが削除されたら、DBからも仮想デバイスを削除する。
        DPIRKitDBManager *mgr = [DPIRKitDBManager sharedInstance];
        [mgr deleteVirtualDevice:service.serviceId];
        [mgr deleteRESTfulRequestForServiceId:service.serviceId];
    }
}
- (void)didSelectService:(DConnectService *)service
{
    
    // サービスが選択されたら、仮想デバイス一覧画面を表示する
    
    // iphoneとipadでストーリーボードを切り替える
    NSBundle *bundle = DPIRBundle();
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPhone", DPIRKitStoryBoardName]
                                               bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPad", DPIRKitStoryBoardName]
                                               bundle:bundle];
    }
    UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"virtualDeviceList"];
    
    UIViewController *rootView;
    DCPutPresentedViewController(rootView);
    DPIRKitVirtualDeviceViewController *view = (DPIRKitVirtualDeviceViewController*) top.viewControllers[0];
    if (service.serviceId) {
        // IRKitのServiceIdに.がある場合は仮想デバイスとみなす
        NSRange range = [service.serviceId rangeOfString:@"."];
        if (range.location != NSNotFound) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"仮想デバイス"
                                                                                     message:@"このデバイスは仮想デバイスのため、さらに仮想デバイスを作ることはできません。"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [rootView presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        
        [view setDetailName:service.serviceId];
        [view setProvider:super.serviceProvider];
        [rootView presentViewController:top animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"不明なデバイス"
                                                                                 message:@"このデバイスは不明です"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [rootView presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (void) serviceListViewControllerDidWillAppear {
    [self startObeservation];
}



#pragma mark DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return super.serviceProvider;
}

- (UIViewController *)settingViewController {
    NSBundle *bundle = DPIRBundle();
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPhone", DPIRKitStoryBoardName]
                                               bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPad", DPIRKitStoryBoardName]
                                               bundle:bundle];
    }
    UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"setting"];

    return top;
}

#pragma mark DConnectInformationProfileDataSource

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                                    wifiStateForServiceId:(NSString *)serviceId
{
    
    DConnectServiceInformationProfileConnectState state = DConnectServiceInformationProfileConnectStateOff;
    @synchronized (_devices) {
        if (_devices.count > 0) {
            DPIRKitDevice *device = _devices[serviceId];
            if (device) {
                state = DConnectServiceInformationProfileConnectStateOn;
            }
        }
    }
    
    return state;
}

// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    DPIRKitNetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    if (networkStatus == DPIRKitNotReachable) {
        // ネット接続が切断されたので全サービスをオフラインにする
        for (DConnectService *service in self.serviceProvider.services) {
            [service setOnline: NO];
        }
    }
}


#pragma mark - DPIRKitManagerDetectionDelegate

- (void) manager:(DPIRKitManager *)manager didFindDevice:(DPIRKitDevice *)device {
    
    DPIRLog(@"found a device : %@", device);
    [self sendDeviceDetectionEventWithDevice:device online:YES];
}

- (void) manager:(DPIRKitManager *)manager didLoseDevice:(DPIRKitDevice *)device {
    DPIRLog(@"lost a device : %@", device);
    [self sendDeviceDetectionEventWithDevice:device online:NO];
}



- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceIRKit_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceIRKit_resources" ofType:@"bundle"]];
}

@end
