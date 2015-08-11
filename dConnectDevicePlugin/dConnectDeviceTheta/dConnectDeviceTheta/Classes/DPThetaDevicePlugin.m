//
//  dConnectDeviceTheta.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaDevicePlugin.h"
#import "DPThetaBatteryProfile.h"
#import "DPThetaFileProfile.h"
#import "DPThetaMediaStreamRecordingProfile.h"
#import "DPThetaServiceDiscoveryProfile.h"
#import "DPThetaSystemProfile.h"
#import "DPThetaManager.h"

@implementation DPThetaDevicePlugin


- (id) init
{
    self = [super init];
    if (self) {
        self.pluginName = @"Theta 1.0.0";
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        [self addProfile:[DPThetaBatteryProfile new]];
        [self addProfile:[DPThetaFileProfile new]];
        [self addProfile:[DPThetaMediaStreamRecordingProfile new]];
        [self addProfile:[DPThetaServiceDiscoveryProfile new]];
        [self addProfile:[DPThetaSystemProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];

        
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
         setController:[DConnectDBCacheController
                        controllerWithClass:key]];
        
        // プロファイルを追加
        [self addProfile:[DConnectServiceInformationProfile new]];
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            
            [notificationCenter addObserver:_self selector:@selector(applicationdidFinishLaunching)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
            
            [notificationCenter addObserver:_self selector:@selector(enterBackground)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:application];
            
        });
    }
    
    return self;
}

// 後始末
- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
   
}

//バックグラウンド
- (void) enterBackground {
    [[DPThetaManager sharedManager] disconnect];
}

// 起動時
- (void)applicationdidFinishLaunching
{
    [[DPThetaManager sharedManager] connect];
}




@end
