//
//  TopViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "TopViewModel.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation TopViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[GHURLManager alloc]init];
        self.url = @"http://www.google.com";
    }
    return self;
}

- (void)initialSetup
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    BOOL isOriginBlock = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;
}

- (void)finishOriginBlock
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    [[NSUserDefaults standardUserDefaults] setBool:mgr.settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
}

- (NSString*)checkUrlString:(NSString*)url
{
    //文字列がURLの場合
    self.url = [self.manager isURLString:url];
    if ([url rangeOfString:@"#"].location != NSNotFound) {
        self.url = url;
    } else if (!self.url) {
        self.url = [self.manager createSearchURL:url];
    }
    return self.url;
}


- (NSString*)makeURLFromNotification:(NSNotification*)notif
{
    NSDictionary *dict = notif.userInfo;
    NSString* url = [dict objectForKey:PAGE_URL];
    self.url = url;
    if ([self.url rangeOfString:@"%23"].location != NSNotFound) {
        self.url = [self.url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"] ;
    } else if (![self.manager isURLString:self.url]) {
        self.url = [self.manager createSearchURL:url];
    }
    return self.url;
}

@end
