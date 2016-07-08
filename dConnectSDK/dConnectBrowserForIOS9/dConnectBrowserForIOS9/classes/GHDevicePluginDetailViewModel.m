//
//  GHDevicePluginDetailViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
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


- (DConnectSystemProfile<DConnectSystemProfileDataSource> *)findSystemProfile
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
