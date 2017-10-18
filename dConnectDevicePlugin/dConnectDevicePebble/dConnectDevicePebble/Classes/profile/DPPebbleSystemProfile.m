//
//  DPPebbleSystemProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleSystemProfile.h"
#import "PebbleViewController.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"
#import <DConnectSDK/DConnectServiceListViewController.h>

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

@interface DPPebbleSystemProfile ()
@end

@implementation DPPebbleSystemProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
        self.delegate = self;
		self.dataSource = self;
        __weak DPPebbleSystemProfile *weakSelf = self;
        
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
                            
                            [[DPPebbleManager sharedManager] deleteAllEvents:^(NSError *error) {
                                [response setResult:DConnectMessageResultTypeOk];
                                [[DConnectManager sharedManager] sendResponse:response];
                            }];
                            return NO;
                        }];
	}
	return self;
}


#pragma mark - DConnectSystemProfileDelegate & DataSource

// 設定画面用のUIViewController
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
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDevicePebble_resources" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

	// iphoneとipadでストーリーボードを切り替える
	UIStoryboard *storyBoard;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		storyBoard = [UIStoryboard storyboardWithName:@"dConnectDevicePebble_iPhone" bundle:bundle];
	} else{
		storyBoard = [UIStoryboard storyboardWithName:@"dConnectDevicePebble_iPad" bundle:bundle];
	}
	UINavigationController *viewController = [storyBoard instantiateInitialViewController];

	return viewController;
*/
}

#pragma mark - DConnectSystemProfileDelegate

- (DConnectServiceProvider *)serviceProvider {
    return ((DConnectDevicePlugin *)self.plugin).serviceProvider;
}

- (UIViewController *)settingViewController {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDevicePebble_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"dConnectDevicePebble_iPhone" bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:@"dConnectDevicePebble_iPad" bundle:bundle];
    }
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    
    return viewController;
}

@end
