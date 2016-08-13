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
    }
    return self;
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
    
    // デバイス管理情報更新
    [self updateManageServices];
    
    return YES;
}

- (BOOL) hasDataAvaiableEvent {
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self class]];
    NSArray *evts = [mgr eventListForServiceId:SERVICE_ID
                                       profile:DConnectMediaStreamRecordingProfileName
                                     attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
    return evts.count > 0;
}


// デバイス管理情報更新
- (void) updateManageServices {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.plugin.serviceProvider) {
            return;
        }
        
        int deviceCount = (int)[DeviceList getSize];
        
        // ServiceProviderに存在するサービスが検出されなかったならオフラインにする
        for (DConnectService *service in [self.plugin.serviceProvider services]) {
            NSString *serviceId = [service serviceId];
            
            BOOL isFindDevice = NO;
            for (int deviceIndex = 0; deviceIndex < deviceCount; deviceIndex ++) {
                NSString *deviceServiceId = [NSString stringWithFormat:@"%d", deviceIndex];
                if (deviceServiceId && [serviceId localizedCaseInsensitiveCompare: deviceServiceId] == NSOrderedSame) {
                    isFindDevice = YES;
                    break;
                }
            }
            
            if (!isFindDevice) {
                [service setOnline: NO];
            }
        }
        
        // サービス未登録なら登録する
        for (int deviceIndex = 0; deviceIndex < deviceCount; deviceIndex ++) {
            NSString *deviceServiceId = [NSString stringWithFormat:@"%d", deviceIndex];
            NSString *deviceName = SonyDeviceName;
            if (![self.plugin.serviceProvider service: deviceServiceId]) {
                SonyCameraService *service = [[SonyCameraService alloc] initWithServiceId:deviceServiceId
                                                                               deviceName:deviceName
                                                                                   plugin: self.plugin
                                                                         liveViewDelegate:self.liveViewDelegate
                                                                    remoteApiUtilDelegate:self.remoteApiUtilDelegate];
                [self.plugin.serviceProvider addService: service];
            }
        }
    }
}

@end
