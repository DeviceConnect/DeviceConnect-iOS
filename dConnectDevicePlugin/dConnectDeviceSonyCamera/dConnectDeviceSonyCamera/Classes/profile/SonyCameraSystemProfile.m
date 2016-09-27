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

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

/*!
 @brief バージョン。
 */
NSString *const SonyDevicePluginVersion = @"2.0.0";


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
                         
                         BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
                         return send;
                     }];
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *deleteEventsRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectSystemProfileAttrEvents];
        [self addDeletePath: deleteEventsRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *origin = [request origin];
                            
                            if (origin == nil) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil"];
                            } else {
                                DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[SonyCameraDevicePlugin class]];
                                if ([mgr removeEventsForOrigin:origin]) {
                                    [response setResult:DConnectMessageResultTypeOk];
                                    
                                    // 削除した時にイベントが残っていなければ、プレビューを止める
                                    SonyCameraManager *manager = [SonyCameraManager sharedManager];
                                    if (![self hasDataAvaiableEvent] && [[manager remoteApi] isStartedLiveView]) {
                                        [[manager remoteApi] actStopLiveView];
                                    }
                                } else {
                                    [response setErrorToUnknownWithMessage:@"Cannot delete events."];
                                }
                            }
                            return YES;
                        }];
    }
    return self;
}


#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return SonyDevicePluginVersion;
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
    NSString *bundlePath = [[NSBundle mainBundle]
                            pathForResource:@"dConnectDeviceSonyCamera_resources"
                            ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPhone" bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPad" bundle:bundle];
    }
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
    for (int i = 0; i < viewController.viewControllers.count; i++) {
        UIViewController *ctl = viewController.viewControllers[i];
        NSString *className = NSStringFromClass([ctl class]);
        if ([className isEqualToString:@"SonyCameraViewController"]) {
            SonyCameraViewController *scvc = (SonyCameraViewController *) ctl;
            scvc.deviceplugin = manager.plugin;
        }
    }
    return viewController;
*/
}


#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    NSString *bundlePath = [[NSBundle mainBundle]
                            pathForResource:@"dConnectDeviceSonyCamera_resources"
                            ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPhone" bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:@"SonyCameraDevicePlugin_iPad" bundle:bundle];
    }
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    SonyCameraManager *manager = [SonyCameraManager sharedManager];
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


#pragma mark - Primate Methods.

- (BOOL) hasDataAvaiableEvent {
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[SonyCameraDevicePlugin class]];
    NSArray *evts = [mgr eventListForServiceId:SERVICE_ID
                                       profile:DConnectMediaStreamRecordingProfileName
                                     attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
    return evts.count > 0;
}

@end
