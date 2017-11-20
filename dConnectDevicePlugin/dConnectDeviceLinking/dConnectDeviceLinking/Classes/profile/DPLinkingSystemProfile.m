//
//  DPLinkingSystemProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingSystemProfile.h"

@interface DPLinkingSystemProfile () <DConnectSystemProfileDataSource>

@end

@implementation DPLinkingSystemProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf didReceivePutWakeupRequest:request response:response];
                     }];
    }
    return self;
}

+ (instancetype) systemProfile
{
    return [DPLinkingSystemProfile new];
}

#pragma mark - DConnectSystemProfileDataSource


- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    return [storyboard instantiateInitialViewController];
}

@end
