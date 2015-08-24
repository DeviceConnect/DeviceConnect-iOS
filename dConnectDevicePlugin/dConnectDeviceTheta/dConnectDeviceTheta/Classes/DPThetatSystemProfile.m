//
//  DPThetaSystemProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPThetaDevicePlugin.h"
#import "DPThetaSystemProfile.h"

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
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPThetaDevicePlugin class]];
    }
    return self;
}

#pragma mark - DConnectSystemProfileDelegate


#pragma mark - Delete Methods

- (BOOL)              profile:(DConnectSystemProfile *)profile
didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                   sessionKey:(NSString *)sessionKey
{
    if ([_eventMgr removeEventsForSessionKey:sessionKey]) {
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToUnknownWithMessage:
         @"Failed to remove events associated with the specified session key."];
    }
    
    return YES;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"1.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
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
