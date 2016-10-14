//
//  dConnectDeviceTheta.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaDevicePlugin.h"
#import "DPThetaSystemProfile.h"
#import "DPThetaManager.h"

@implementation DPThetaDevicePlugin


- (id) init
{
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Theta (Device Connect Device Plug-in)";
        [[DPThetaManager sharedManager] setServiceProvider: self.serviceProvider];
        [[DPThetaManager sharedManager] setPlugin:self];
        [[DPThetaManager sharedManager] init];
        
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        [self addProfile:[DPThetaSystemProfile new]];
        
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
         setController:[DConnectDBCacheController
                        controllerWithClass:key]];
    }
    
    return self;
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPThetaBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

@end
