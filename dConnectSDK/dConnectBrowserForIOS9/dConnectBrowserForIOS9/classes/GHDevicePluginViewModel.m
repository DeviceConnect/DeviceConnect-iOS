//
//  GHDevicePluginViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDevicePluginViewModel.h"

@implementation GHDevicePluginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datasource = [[NSMutableArray alloc]init];
        [self setDevicePluginsList];
    }
    return self;
}

- (void)setDevicePluginsList
{
    self.datasource = [[DConnectManager sharedManager] devicePluginsList];
}

- (NSDictionary*)makePlguinAndProfiles:(NSInteger)index
{
    DConnectDevicePlugin* plugin = [self.datasource objectAtIndex: index];
    return @{
             @"plugin": plugin,
             @"profiles": [plugin profiles]
             };
}
- (NSDictionary*)makePlguinAndPlugins:(DConnectDevicePlugin*)plugin
{
    return @{
             @"plugin": plugin,
             @"profiles": [plugin profiles]
             };
}
- (void)dealloc
{
    self.datasource = nil;
}
@end
