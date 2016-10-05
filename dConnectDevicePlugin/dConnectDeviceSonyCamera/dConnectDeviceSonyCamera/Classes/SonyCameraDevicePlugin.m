//
//  SonyCameraDevicePlugin.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraDevicePlugin.h"
#import "SonyCameraRemoteApiUtil.h"
#import "SampleRemoteApi.h"
#import "RemoteApiList.h"
#import "DeviceList.h"
#import "SonyCameraViewController.h"
#import "SampleLiveviewManager.h"
#import "SonyCameraService.h"
#import "SonyCameraManager.h"
#import "SonyCameraSystemProfile.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#define DPSonyCameraBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceSonyCamera_resources" ofType:@"bundle"]]

/*!
 @brief Sony Remote Camera用デバイスプラグイン。
 */
@interface SonyCameraDevicePlugin() <SampleDiscoveryDelegate,
                            SampleLiveviewDelegate,
                            SonyCameraRemoteApiUtilDelegate>

/*!
 @brief 1970/1/1からの時間を取得する。
 @return 時間
 */
- (UInt64) getEpochMilliSeconds;

/*!
 @brief 現在接続されているWifiのSSIDからSony Cameraかチェックする.
 @retval YES Sony Cameraの場合
 @retval NO Sony Camera以外
 */
- (BOOL) checkSSID;

@end


#pragma mark - SonyCameraDevicePlugin

@implementation SonyCameraDevicePlugin

- (instancetype) init {
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Sony Camera (Device Connect Device Plug-in)";
        
        (void)[[SonyCameraManager sharedManager] initWithPlugin:self liveViewDelegate:self remoteApiUtilDelegate:self];
        
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key] setController:[DConnectMemoryCacheController new]];
        
        [[SonyCameraManager sharedManager] setServiceProvider: self.serviceProvider];
        [[SonyCameraManager sharedManager] setPlugin:self];
        
        // System Profileの追加
        [self addProfile:[SonyCameraSystemProfile new]];
        
        
        if ([self checkSSID]) {
            [self searchSonyCameraDevice];
        }
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            
            [notificationCenter addObserver:_self selector:@selector(applicationWillEnterForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:application];
            
        });
    }
    return self;
}


#pragma mark - Public Methods -

- (void) searchSonyCameraDevice {
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    if (manager.searchFlag) {
        return;
    }
    manager.searchFlag = YES;
    
    // 検索する前にリセットをしておく
    [DeviceList reset];
    [[SampleCameraEventObserver getInstance] destroy];
	// Sony Camera デバイスの探索
	SampleDeviceDiscovery* discovery = [SampleDeviceDiscovery new];
	[discovery performSelectorInBackground:@selector(discover:) withObject:self];
}

- (void) stop {
    [DeviceList reset];
    [[SampleCameraEventObserver getInstance] destroy];
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    if ([manager.remoteApi isStartedLiveView]) {
        [manager.remoteApi actStopLiveView];
    }
    manager.remoteApi = nil;
}

- (BOOL) isStarted {
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    return manager.remoteApi != nil;
}

#pragma mark - Private Methods -

- (void) applicationWillEnterForeground
{
    // バックグラウンドから復帰したときの処理
    if ([self checkSSID]) {
        SonyCameraManager *manager = [SonyCameraManager sharedManager];
        if (manager.remoteApi == nil) {
            [self searchSonyCameraDevice];
        } else {
            NSLog(@"TEST: %d",  [[SampleCameraEventObserver getInstance] isStarted]);
        }
    } else {
        [self stop];
    }
}

- (UInt64) getEpochMilliSeconds
{
    return (UInt64)floor((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000.0);
}

- (BOOL) checkSSID {
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    if (!interfaces) return NO;
    if (CFArrayGetCount(interfaces)==0) return NO;
    CFDictionaryRef dicRef = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
    if (dicRef) {
        NSString *ssid = CFDictionaryGetValue(dicRef, kCNNetworkInfoKeySSID);
        if ([ssid hasPrefix:@"DIRECT-"]) {
            NSArray *array = @[@"HDR-AS100", @"ILCE-6000", @"DSC-HC60V", @"DSC-HX400",
                               @"ILCE-5000", @"DSC-QX10", @"DSC-QX100", @"HDR-AS15",
                               @"HDR-AS30", @"HDR-MV1", @"NEX-5R", @"NEX-5T", @"NEX-6",
                               @"ILCE-7R/B", @"ILCE-7/B"];
            for (NSString *name in array) {
                NSRange searchResult = [ssid rangeOfString:name];
                if (searchResult.location != NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark - SampleDiscoveryDelegate

- (void) didReceiveDeviceList:(BOOL) discovery {
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    manager.searchFlag = NO;

    if (discovery) {
        manager.remoteApi = [SonyCameraRemoteApiUtil new];
        manager.remoteApi.delegate = self;
        
        // プレビューイベントを持っている場合は、プレビューを再開させる
        if ([manager hasDataAvaiableEvent] && ![manager.remoteApi isStartedLiveView]) {
            [manager.remoteApi actStartLiveView:self];
        }
    }
    
    // デバイス管理情報更新
    [manager updateManageServices];

    [self.delegate didReceiveDeviceList:discovery];

}

#pragma mark - SampleLiveviewDelegate -

- (void) didReceivedData:(NSData *)imageData
{
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    
    // プレビューのタイムスライス時間に満たない場合には無視する
    UInt64 time = [self getEpochMilliSeconds];
    if (time - manager.previewStart < manager.timeslice) {
        return;
    }
    manager.previewStart = time;
    
    manager.mPreviewCount++;
    manager.mPreviewCount %= 10;
    
    // ファイル名を作成
    NSString *fileName = [NSString stringWithFormat:@"preview%d.jpg", manager.mPreviewCount];
    // ファイルを保存
    NSString *uri = [manager.mFileManager createFileForPath:fileName contents:imageData];
    if (uri) {
        // イベントの作成
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setUri:uri target:media];
        [DConnectMediaStreamRecordingProfile setPath:fileName target:media];
        
        // イベントの取得
        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self class]];
        NSArray *evts = [mgr eventListForServiceId:SERVICE_ID
                                          profile:DConnectMediaStreamRecordingProfileName
                                        attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        // イベント送信
        for (DConnectEvent *evt in evts) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
            [eventMsg setMessage:media forKey:DConnectMediaStreamRecordingProfileParamMedia];
            [self sendEvent:eventMsg];
        }
    }
}

- (void) didReceivedError {
    [self stop];
    [self searchSonyCameraDevice];
}


#pragma mark - SonyCameraRemoteApiUtilDelegate

- (void) didReceivedImage:(NSString *)imageUrl
{
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *picture = [manager download:imageUrl];
        if (picture) {
            NSString *uri = [manager saveFile:picture];
            if (!uri) {
                return;
            }
            
            // イベント作成
            DConnectMessage *photo = [DConnectMessage message];
            [DConnectMediaStreamRecordingProfile setUri:uri target:photo];
            [DConnectMediaStreamRecordingProfile setPath:[uri lastPathComponent] target:photo];
            [DConnectMediaStreamRecordingProfile setMIMEType:@"image/png" target:photo];
            
            // イベントの取得
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self class]];
            NSArray *evts = [mgr eventListForServiceId:SERVICE_ID
                                              profile:DConnectMediaStreamRecordingProfileName
                                            attribute:DConnectMediaStreamRecordingProfileAttrOnPhoto];
            // イベント送信
            for (DConnectEvent *evt in evts) {
                DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
                [eventMsg setMessage:photo forKey:DConnectMediaStreamRecordingProfileParamPhoto];
                [manager.plugin sendEvent:eventMsg];
            }
        }
    });
}


- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPSonyCameraBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

@end
