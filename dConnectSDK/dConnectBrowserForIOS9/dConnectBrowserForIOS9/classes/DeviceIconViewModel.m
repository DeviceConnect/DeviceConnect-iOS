//
//  DeviceIconViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "DeviceIconViewModel.h"

@implementation DeviceIconViewModel

- (NSString*)name
{
    return (NSString*)[self.message arrayForKey:@"name"];
}

- (BOOL)isOnline
{
    return (BOOL)[self.message arrayForKey:@"online"];
}

- (NSString*)idName
{
    return (NSString*)[self.message arrayForKey:@"id"];
}

- (NSString*)type
{
    return (NSString*)[self.message arrayForKey:@"type"];
}

- (void)dealloc
{
    self.message = nil;
}

@end
