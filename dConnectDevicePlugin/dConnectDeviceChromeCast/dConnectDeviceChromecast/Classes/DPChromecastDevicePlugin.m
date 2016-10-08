//
//  DPChromecastDevicePlugin.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastDevicePlugin.h"
#import "DPChromecastSystemProfile.h"
#import "DPChromecastManager.h"

#define DPChromecastBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"]]

@implementation DPChromecastDevicePlugin

- (id) init {
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"ChromeCast (Device Connect Device Plug-in)";
        
        [[DPChromecastManager sharedManager] setServiceProvider: self.serviceProvider];
        [[DPChromecastManager sharedManager] setPlugin:self];
        
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
                        setController:[DConnectDBCacheController
                  controllerWithClass:key]];

        // プロファイルを追加
        [self addProfile:[DPChromecastSystemProfile new]];

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
            DPChromecastManager *mgr = [DPChromecastManager sharedManager];
            [mgr setServiceProvider: self.serviceProvider];
            [mgr setPlugin: self];
            [mgr startScan];
            [mgr startHttpServer];

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
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr stopScan];
    [mgr stopHttpServer];

}

//バックグラウンド
- (void) enterBackground {
    
    // スキャン停止
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr stopScan];
    [mgr stopHttpServer];
}

// 起動時
- (void)applicationdidFinishLaunching
{
    // スキャン開始
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr startScan];
    [mgr startHttpServer];
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPChromecastBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

@end

