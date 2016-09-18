//
//  SonyCameraManager.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraManager.h"
#import "DeviceList.h"
#import <DConnectSDK/DConnectService.h>
#import "SonyCameraService.h"
#import "SonyCameraReachability.h"

/*!
 @brief IDのプレフィックス。
 */
NSString *const SonyServiceId = @"sony_camera_";

/*!
 @brief デバイス名。
 */
NSString *const SonyDeviceName = @"Sony Camera";

/*!
 @brief ファイルのプレフィックス。
 */
NSString *const SonyFilePrefix = @"sony";

@interface SonyCameraManager()

@property (nonatomic, strong) SonyCameraReachability *reachability;

@end

@implementation SonyCameraManager

// share instance
+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceSonyCameraToken;
    dispatch_once(&onceSonyCameraToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// init
- (instancetype)initWithPlugin: (SonyCameraDevicePlugin *) plugin
              liveViewDelegate: (id<SampleLiveviewDelegate>) liveViewDelegate
         remoteApiUtilDelegate: (id<SonyCameraRemoteApiUtilDelegate>) remoteApiUtilDelegate
{
    self = [super init];
    if (self) {
        self.timeslice = 200;
        self.previewStart = 0;
        self.remoteApi = nil;
        self.searchFlag = NO;
        self.mFileManager = [DConnectFileManager fileManagerForPlugin:plugin];
        self.plugin = plugin;
        self.liveViewDelegate = liveViewDelegate;
        self.remoteApiUtilDelegate = remoteApiUtilDelegate;
        
        // Reachabilityの初期処理
        self.reachability = [SonyCameraReachability reachabilityWithHostName: @"www.google.com"];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(notifiedNetworkStatus:)
         name:kReachabilityChangedNotification
         object:nil];
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    // Reachabilityの終了処理
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

// デバイス管理情報更新
- (void) updateManageServices {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.serviceProvider) {
            return;
        }
        
        int deviceCount = (int)[DeviceList getSize];
        
        // ServiceProviderに存在するサービスが検出されなかったならオフラインにする
        for (DConnectService *service in [self.serviceProvider services]) {
            NSString *serviceId = [service serviceId];

            // SonyCamera以外は対象外
            if ([[service name] localizedCaseInsensitiveCompare: SonyDeviceName] != NSOrderedSame) {
                continue;
            }
            
            // ServiceProviderにあって最新のリストに無い場合はオフラインにする。有ればオンラインにする
            BOOL isFindDevice = NO;
            for (int deviceIndex = 0; deviceIndex < deviceCount; deviceIndex ++) {
                NSString *deviceServiceId = [NSString stringWithFormat:@"%d", deviceIndex];
                if (deviceServiceId && [serviceId localizedCaseInsensitiveCompare: deviceServiceId] == NSOrderedSame) {
                    isFindDevice = YES;
                    break;
                }
            }
            if (isFindDevice) {
                [service setOnline: YES];
            } else {
                [service setOnline: NO];
            }
        }
        
        // サービス未登録なら登録する
        for (int deviceIndex = 0; deviceIndex < deviceCount; deviceIndex ++) {
            NSString *deviceServiceId = [NSString stringWithFormat:@"%d", deviceIndex];
            NSString *deviceName = SonyDeviceName;
            if (![self.serviceProvider service: deviceServiceId]) {
                SonyCameraService *service = [[SonyCameraService alloc] initWithServiceId:deviceServiceId
                                                                               deviceName:deviceName
                                                                                   plugin: self.plugin
                                                                         liveViewDelegate:self.liveViewDelegate
                                                                    remoteApiUtilDelegate:self.remoteApiUtilDelegate];
                [self.serviceProvider addService: service];
                [service setOnline: YES];
            }
        }
    }
}

#pragma mark - Private Methods -

- (NSData *) download:(NSString *)requestURL {
    NSURL *downoadUrl = [NSURL URLWithString:requestURL];
    NSData *urlData = [NSData dataWithContentsOfURL:downoadUrl];
    return urlData;
}

- (NSString *) saveFile:(NSData *)data
{
    // ファイル名作成
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", SonyFilePrefix, dateStr];
    
    // ファイルを保存
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    return [manager.mFileManager createFileForPath:fileName contents:data];
}

- (BOOL) selectServiceId:(NSString *)serviceId response:(DConnectResponseMessage *)response {
    // サービスIDの存在チェック
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return NO;
    }
    
    // デバイスが存在しない
    if ([DeviceList getSize] <= 0) {
        [response setErrorToNotFoundService];
        return NO;
    }
    
    // デバイス選択
    NSInteger idx = [serviceId integerValue];
    [DeviceList selectDeviceAt:idx];
    
    return YES;
}

- (BOOL) hasDataAvaiableEvent {
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self.plugin class]];
    NSArray *evts = [mgr eventListForServiceId:SERVICE_ID
                                       profile:DConnectMediaStreamRecordingProfileName
                                     attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
    return evts.count > 0;
}

// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    [self updateManageServices];
}

@end
