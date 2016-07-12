//
//  DPHostDevicePlugin.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectFileManager.h>
#import <DConnectSDK/DConnectEventManager.h>
#import <DConnectSDK/DConnectMemoryCacheController.h>

#import "DPHostDevicePlugin.h"

#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostSystemProfile.h"

@implementation DPHostDevicePlugin

+ (void) initialize {
    // イベントマネージャの準備
    Class clazz = [DPHostDevicePlugin class];
    DConnectEventManager *eventMgr =
    [DConnectEventManager sharedManagerForClass:clazz];
    [eventMgr setController:[DConnectMemoryCacheController new]];
}

- (id) init {
    self = [super init];
    if (self) {
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        
        self.pluginName = @"Host (Device Connect Device Plug-in)";
        
        // プロファイルを追加
        [self addProfile:[[DPHostServiceDiscoveryProfile alloc] initWithFileManager:self.fileMgr]];
        [self addProfile:[DPHostSystemProfile new]];
    }
    return self;
}

- (NSString *) pathByAppendingPathComponent:(NSString *)pathComponent
{
    return [self.fileMgr.URL URLByAppendingPathComponent:pathComponent].standardizedURL.path;
}

@end
