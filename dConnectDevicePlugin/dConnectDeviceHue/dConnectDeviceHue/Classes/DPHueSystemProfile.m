//
//  DPHueSystemProfile.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueSystemProfile.h"

@implementation DPHueSystemProfile
- (id)init
{
    self = [super init];
    if (self) {
        self.dataSource = self;
        __weak DPHueSystemProfile *weakSelf = self;
        
        // API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
                         return send;
                     }];
    }
    return self;
}

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile
{
    return @"2.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceHue_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"HueSetting_iPhone" bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:@"HueSetting_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
}

@end
