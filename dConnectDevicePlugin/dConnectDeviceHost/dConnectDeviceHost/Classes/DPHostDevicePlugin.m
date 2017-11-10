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
#import <DConnectSDK/DConnectServiceManager.h>

#import "DPHostDevicePlugin.h"
#import "DPHostSystemProfile.h"
#import "DPHostService.h"

#define DPHostBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]]

@implementation DPHostDevicePlugin

+ (void) initialize {
}

- (id) init {
    self = [super initWithObject: self];
    if (self) {
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        self.pluginName = @"Host (Device Connect Device Plug-in)";
        
        // サービス追加
        DConnectService *hostService = [[DPHostService alloc] initWithFileManager: self.fileMgr plugin: self];
        [self.serviceProvider addService: hostService];
        [hostService setOnline: YES];
        
        // プロファイルを追加
        [self addProfile:[DPHostSystemProfile new]];
    }
    return self;
}

- (NSString *) pathByAppendingPathComponent:(NSString *)pathComponent
{
    return [self.fileMgr.URL URLByAppendingPathComponent:pathComponent].standardizedURL.path;
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPHostBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}

#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]];
}
@end
