//
//  SonyCameraDevicePlugin.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraDevicePlugin.h"
#import "SonyCameraViewController.h"
#import "SonyCameraService.h"
#import "SonyCameraManager.h"
#import "SonyCameraSystemProfile.h"
#import "SonyCameraMediaStreamRecordingProfile.h"
#import <SystemConfiguration/CaptiveNetwork.h>

/*!
 @brief Sony Remote Camera用デバイスプラグイン。
 */
@interface SonyCameraDevicePlugin() <SonyCameraManagerDelegate>

@end


#pragma mark - SonyCameraDevicePlugin

@implementation SonyCameraDevicePlugin

- (instancetype) init {
    self = [super initWithObject: self];
    if (self) {
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key] setController:[DConnectMemoryCacheController new]];

        self.pluginName = @"Sony Camera (Device Connect Device Plug-in)";

        self.sonyCameraManager = [[SonyCameraManager alloc] initWithPlugin:self];
        self.sonyCameraManager.delegate = self;
        
        for (SonyCameraService *service in self.sonyCameraManager.sonyCameraServices) {
            [self.serviceProvider addService:service];
        }

        [self addProfile:[SonyCameraSystemProfile new]];
        
        if ([self.sonyCameraManager checkSSID]) {
            [self.sonyCameraManager connectSonyCamera];
        }
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            [notificationCenter addObserver:weakSelf
                                   selector:@selector(applicationWillEnterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
        });
    }
    return self;
}

- (BOOL) isConnectedSonyCamera {
    return [self.sonyCameraManager checkSSID];
}

- (void) removeSonyCamera:(SonyCameraService *)service
{
    [self.sonyCameraManager removeSonyCamera:service];
}

#pragma mark - SonyCameraManagerDelegate Methods

- (void) didDiscoverDeviceList:(BOOL)discovery {
    [self.delegate didReceiveDeviceList:discovery];
}

- (void) didTakePicture:(NSString *)postImageUrl {
    SonyCameraManager *manager = self.sonyCameraManager;
    
    NSString *ssid = [manager getCurrentWifiName];
    
    // イベント作成
    DConnectMessage *photo = [DConnectMessage message];
    [DConnectMediaStreamRecordingProfile setUri:postImageUrl target:photo];
    [DConnectMediaStreamRecordingProfile setMIMEType:@"image/jpg" target:photo];
    
    // イベントの取得
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self class]];
    NSArray *evts = [mgr eventListForServiceId:ssid
                                       profile:DConnectMediaStreamRecordingProfileName
                                     attribute:DConnectMediaStreamRecordingProfileAttrOnPhoto];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [eventMsg setMessage:photo forKey:DConnectMediaStreamRecordingProfileParamPhoto];
        [manager.plugin sendEvent:eventMsg];
    }
}

- (void) didAddedService:(SonyCameraService *)service {
    
    // NSLog(@"didAddedService:%@", service.name);
    [self.serviceProvider addService:service];
}

- (void) didReceiveWiFiStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveUpdateDevice)]) {
        [self.delegate didReceiveUpdateDevice];
    }
}

#pragma mark - DConnectDevicePlugin Methods

- (void) applicationWillEnterForeground
{
    // NSLog(@"applicationWillEnterForeground");
    if ([self.sonyCameraManager checkSSID]) {
        // NSLog(@"checkSSID YES");
        [self.sonyCameraManager connectSonyCamera];
    } else {
        // NSLog(@"checkSSID NO");
        [self.sonyCameraManager disconnectSonyCamera];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveUpdateDevice)]) {
        // NSLog(@"didReceiveUpdateDevice");
        [self.delegate didReceiveUpdateDevice];
    }
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPSonyCameraBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

@end
