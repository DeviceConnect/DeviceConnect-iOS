//
//  DPChromecastSystemProfile.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceListViewController.h>
#import "DPChromecastSystemProfile.h"
#import "DPChromecastDevicePlugin.h"

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

@implementation DPChromecastSystemProfile

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        __weak DPChromecastSystemProfile *weakSelf = self;
        
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
                            
                            DConnectEventManager *eventMgr = [DConnectEventManager sharedManagerForClass:[DPChromecastDevicePlugin class]];
                            if ([eventMgr removeEventsForOrigin:origin]) {
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


// デバイスプラグインの設定画面用のUIViewControllerを要求する
-(UIViewController *) profile:(DConnectSystemProfile *)sender
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
    // 設定画面用のViewControllerをStoryboardから生成する
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Chromecast_iPhone" bundle:bundle];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:@"Chromecast_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
*/
}


#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    // 設定画面用のViewControllerをStoryboardから生成する
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Chromecast_iPhone" bundle:bundle];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:@"Chromecast_iPad" bundle:bundle];
    }
    return [storyBoard instantiateInitialViewController];
}

@end
