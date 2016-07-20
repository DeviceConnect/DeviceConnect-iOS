//
//  GHDevicePluginViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/07.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDevicePluginViewModel.h"
#import <DConnectSDK/DConnectSDK.h>

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

- (void)dealloc
{
    self.datasource = nil;
}
@end
