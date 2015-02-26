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

NSString *const DPIRKitInfoVersion = @"DPIRKitVersion";
NSString *const DPIRKitInfoAPIKey = @"DPIRKitAPIKey";
NSString *const DPIRKitStoryBoardName = @"Storyboard_";
NSString *const DPIRKitPluginName = @"IRKit 1.0.1";

// Const.h
NSString *const DPIRKitBundleName = @"dConnectDeviceIRKit_resources";
NSString *const DPIRKitInfoPlistName = @"dConnectDeviceIRKit-Info";

@interface DPIRKitDevicePlugin()
<
// プロファイルデリゲート
DConnectServiceDiscoveryProfileDelegate,
DConnectSystemProfileDataSource,

// デバイス検知デリゲート
DPIRKitManagerDetectionDelegate
>

{
    NSMutableDictionary *_devices;
    DConnectEventManager *_eventManager;
    NSString *_version;
}

- (void) sendDeviceDetectionEventWithDevice:(DPIRKitDevice *)device online:(BOOL)online;

- (void) startObeservation;
- (void) stopObeservation;

@end

@implementation DPIRKitDevicePlugin

#pragma mark - Initializaion

- (id) init {
    
    self = [super init];
    
    if (self) {
        DConnectServiceDiscoveryProfile *serviceDiscoveryProfile = [DConnectServiceDiscoveryProfile new];
        DConnectSystemProfile *systemProfile = [DConnectSystemProfile new];
        DPIRKitRemoteControllerProfile *remoteControllerProfile
                            = [[DPIRKitRemoteControllerProfile alloc] initWithDevicePlugin:self];
        serviceDiscoveryProfile.delegate = self;
        systemProfile.dataSource = self;
        [self addProfile:serviceDiscoveryProfile];
        [self addProfile:systemProfile];
        [self addProfile:remoteControllerProfile];
        _devices = [NSMutableDictionary dictionary];
        id<DConnectEventCacheController> controller = [[DConnectMemoryCacheController alloc] init];
        _eventManager = [DConnectEventManager sharedManagerForClass:[DPIRKitDevicePlugin class]];
        [_eventManager setController:controller];
        NSString* path = [DPIRBundle() pathForResource:DPIRKitInfoPlistName ofType:@"plist"];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
        _version = info[DPIRKitInfoVersion];
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
            DPIRKitManager *manager = [DPIRKitManager sharedInstance];
            manager.apiKey = info[DPIRKitInfoAPIKey];
            manager.detectionDelegate = _self;
            
            [_self startObeservation];
        });
        self.pluginName = DPIRKitPluginName;
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
        return [_devices objectForKey:serviceId];
    }
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
        
        DConnectMessage *networkService = [DConnectMessage message];
        [DConnectServiceDiscoveryProfile setId:device.name target:networkService];
        [DConnectServiceDiscoveryProfile setName:device.name target:networkService];
        [DConnectServiceDiscoveryProfile setType:DConnectServiceDiscoveryProfileNetworkTypeWiFi
                                                 target:networkService];
        [DConnectServiceDiscoveryProfile setState:online target:networkService];
        [DConnectServiceDiscoveryProfile setOnline:online target:networkService];
        
        NSArray *events = [_eventManager eventListForProfile:DConnectServiceDiscoveryProfileName
                                                   attribute:DConnectServiceDiscoveryProfileAttrOnServiceChange];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *message = [DConnectMessage message];
            [message setString:@"" forKey:DConnectMessageServiceId];
            [message setString:DConnectServiceDiscoveryProfileName forKey:DConnectMessageProfile];
            [message setString:DConnectServiceDiscoveryProfileAttrOnServiceChange forKey:DConnectMessageAttribute];
            [message setString:event.sessionKey forKey:DConnectMessageSessionKey];
            [DConnectServiceDiscoveryProfile setNetworkService:networkService target:message];
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

#pragma mark - Profile Delegate
#pragma mark DConnectServiceDiscoveryProfileDelegate

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
{
    
    DConnectArray *services = [DConnectArray array];
    
    @synchronized (_devices) {
        
        for (DPIRKitDevice *device in _devices.allValues) {
            DConnectMessage *service = [DConnectMessage message];
            [DConnectServiceDiscoveryProfile setId:device.name target:service];
            [DConnectServiceDiscoveryProfile setName:device.name target:service];
            // WiFiでのみ接続するので常にWiFi。
            [DConnectServiceDiscoveryProfile setType:DConnectServiceDiscoveryProfileNetworkTypeWiFi
                                                     target:service];
            // 見つかっている時点でWiFiにつながっているので常にYES。
            [DConnectServiceDiscoveryProfile setOnline:YES target:service];
            [services addMessage:service];
        }
    }
    
    response.result = DConnectMessageResultTypeOk;
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    return YES;
}

- (BOOL)                    profile:(DConnectServiceDiscoveryProfile *)profile
didReceivePutOnServiceChangeRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    
    DConnectEventError error = [_eventManager addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        response.result = DConnectMessageResultTypeOk;
        DPIRLog(@"Register ServiceChange Event. %@", sessionKey);
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameter];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveDeleteOnServiceChangeRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    
    DConnectEventError error = [_eventManager removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        response.result = DConnectMessageResultTypeOk;
        DPIRLog(@"Unregister ServiceChange Event. %@", sessionKey);
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameter];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

#pragma mark DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return _version;
}

- (DConnectSystemProfileConnectState) profile:(DConnectSystemProfile *)profile
                         wifiStateForServiceId:(NSString *)serviceId
{
    
    DConnectSystemProfileConnectState state = DConnectSystemProfileConnectStateOff;
    // TODO: 実際に接続を確認した方が良いかの検討
    @synchronized (_devices) {
        if (_devices.count > 0) {
            DPIRKitDevice *device = [_devices objectForKey:serviceId];
            if (device) {
                state = DConnectSystemProfileConnectStateOn;
            }
        }
    }
    
    return state;
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    
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
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    return viewController;
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

@end
