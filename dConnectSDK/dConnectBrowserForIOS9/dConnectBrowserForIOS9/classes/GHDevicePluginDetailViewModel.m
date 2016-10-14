//
//  GHDevicePluginDetailViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "GHDevicePluginDetailViewModel.h"

@implementation GHDevicePluginDetailViewModel
- (instancetype)initWithPlugin:(NSDictionary*)plugin
{
    self = [super init];
    if(self){
        [self setPlugin:plugin];
    }
    return self;
}

- (void)setPlugin:(NSDictionary*)plugin
{
    NSMutableArray *datasource = [[NSMutableArray alloc]initWithCapacity:3];
    DConnectDevicePlugin* devicePlugin = (DConnectDevicePlugin*)[plugin objectForKey:@"plugin"];
    NSArray* profiles = [plugin objectForKey:@"profiles"];

    [datasource addObject:@[devicePlugin]];
    [datasource addObject:@[@(CellTypeTypeHeaderSetting)]];
    [datasource addObject:@[@(CellTypeTypeSetting)]];
    [datasource addObject:@[@(CellTypeTypeHeaderProfile)]];
    [datasource addObject:profiles];
    self.datasource = datasource;
}


- (DConnectSystemProfile*)findSystemProfile
{
    NSArray* profiles = [self.datasource lastObject];
    for (DConnectProfile *profile in profiles) {
        if ([profile.profileName isEqualToString:@"system"]) {
            DConnectSystemProfile *sysProfile = (DConnectSystemProfile *) profile;
            return sysProfile;
            break;
        }
    }
    return nil;
}


- (void)dealloc
{
    self.datasource = nil;
}
@end
