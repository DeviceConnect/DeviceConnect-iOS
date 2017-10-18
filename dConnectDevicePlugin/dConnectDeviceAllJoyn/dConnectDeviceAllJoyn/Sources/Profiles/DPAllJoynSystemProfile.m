//
//  DPAllJoynSystemProfile.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSystemProfile.h"
#import <DConnectSDK/DConnectServiceListViewController.h>
#import "DPAllJoynSettingMasterViewController.h"

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

@interface DPAllJoynSystemProfile () <DConnectSystemProfileDelegate, DConnectSystemProfileDataSource>

@property NSString *const version;

@end


@implementation DPAllJoynSystemProfile

- (instancetype) initWithVersion:(NSString *)version
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.version = version;
        __weak DPAllJoynSystemProfile *weakSelf = self;
        
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


+ (instancetype) systemProfileWithVersion:(NSString *)version {
    DPAllJoynSystemProfile *instance = [self new];
    if (instance) {
        (void)[instance initWithVersion:version];
    }
    return instance;
}


// =============================================================================
#pragma mark DConnectSystemProfileDataSource



- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyBoard;
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    storyBoard = [UIStoryboard storyboardWithName:@"DConnectSDK-iPhone"
                                           bundle:DCBundle()];
    UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"ServiceList"];
    DConnectServiceListViewController *serviceListViewController = (DConnectServiceListViewController *) top.viewControllers[0];
    serviceListViewController.delegate = self;
    return top;
}

#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                         bundle:DPAllJoynResourceBundle()];
    UIViewController *setting = [storyBoard instantiateInitialViewController];
    return setting;
}

@end
