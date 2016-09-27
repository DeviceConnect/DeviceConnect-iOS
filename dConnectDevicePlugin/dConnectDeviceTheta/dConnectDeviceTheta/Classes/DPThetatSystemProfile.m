//
//  DPThetaSystemProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectServiceListViewController.h>

#import "DPThetaDevicePlugin.h"
#import "DPThetaSystemProfile.h"

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

@interface DPThetaSystemProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@end

@implementation DPThetaSystemProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        __weak DPThetaSystemProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPThetaDevicePlugin class]];
        
        // API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
                         return send;
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                            NSString *origin = [request origin];
                            
                            if ([[weakSelf eventMgr] removeEventsForOrigin:origin]) {
                                [response setResult:DConnectMessageResultTypeOk];
                            } else {
                                [response setErrorToUnknownWithMessage:
                                 @"Failed to remove events associated with the specified session key."];
                            }
                            
                            return YES;
                        }];
    }
    return self;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"2.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyBoard;
    storyBoard = [UIStoryboard storyboardWithName:@"DConnectSDK-iPhone"
                                           bundle:DCBundle()];
    UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"ServiceList"];
    DConnectServiceListViewController *serviceListViewController = (DConnectServiceListViewController *) top.viewControllers[0];
    serviceListViewController.delegate = self;
    return top;
    
/*
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceTheta_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Theta_iPhone" bundle:bundle];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:@"Theta_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
*/
}

#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceTheta_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Theta_iPhone" bundle:bundle];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:@"Theta_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
}

@end
