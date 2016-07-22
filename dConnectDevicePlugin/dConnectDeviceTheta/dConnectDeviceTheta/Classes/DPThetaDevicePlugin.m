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
#import "DPThetaOmnidirectionalImageProfile.h"

@implementation DPThetaDevicePlugin


- (id) init
{
    self = [super init];
    if (self) {
        self.pluginName = @"Theta (Device Connect Device Plug-in)";
        
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        [self addProfile:[DPThetaBatteryProfile new]];
        [self addProfile:[DPThetaFileProfile new]];
        [self addProfile:[DPThetaMediaStreamRecordingProfile new]];
        [self addProfile:[DPThetaServiceDiscoveryProfile new]];
        [self addProfile:[DPThetaSystemProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
        [self addProfile:[DPThetaOmnidirectionalImageProfile new]];

        
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
         setController:[DConnectDBCacheController
                        controllerWithClass:key]];
        
        // プロファイルを追加
        [self addProfile:[DConnectServiceInformationProfile new]];
    }
    
    return self;
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceTheta_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

@end
