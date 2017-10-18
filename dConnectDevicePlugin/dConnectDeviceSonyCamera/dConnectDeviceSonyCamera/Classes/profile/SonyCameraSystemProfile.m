//
//  SonyCameraSystemProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraSystemProfile.h"
#import <DConnectSDK/DConnectEventManager.h>
#import <DConnectSDK/DConnectServiceListViewController.h>
#import "SonyCameraDevicePlugin.h"
#import "SonyCameraViewController.h"
#import "SonyCameraManager.h"



@interface SonyCameraSystemProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@end


@implementation SonyCameraSystemProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

        __weak SonyCameraSystemProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[SonyCameraDevicePlugin class]];
        
        // API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf didReceivePutWakeupRequest:request response:response];
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [weakSelf didReceiveDeleteEventsRequest:request response:response];
                        }];
    }
    return self;
}


- (BOOL) didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *origin = [request origin];
    
    if (origin == nil) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil"];
    } else {
        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[SonyCameraDevicePlugin class]];
        if ([mgr removeEventsForOrigin:origin]) {
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToUnknownWithMessage:@"Cannot delete events."];
        }
    }
    return YES;
}

#pragma mark - DConnectSystemProfileDataSource

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
}

#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    NSBundle *bundle = DPSonyCameraBundle();
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPhone" bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPad" bundle:bundle];
    }
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *) self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    for (int i = 0; i < viewController.viewControllers.count; i++) {
        UIViewController *ctl = viewController.viewControllers[i];
        NSString *className = NSStringFromClass([ctl class]);
        if ([className isEqualToString:@"SonyCameraViewController"]) {
            SonyCameraViewController *scvc = (SonyCameraViewController *) ctl;
            scvc.deviceplugin = manager.plugin;
        }
    }
    return viewController;
}

- (void)didRemovedService:(DConnectService *)service
{
    [self.plugin removeSonyCamera:service];
}

@end
