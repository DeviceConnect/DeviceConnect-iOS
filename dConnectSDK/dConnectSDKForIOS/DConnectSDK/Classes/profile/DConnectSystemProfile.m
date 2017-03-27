//
//  DConnectSystemProfile.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSystemProfile.h"
#import "DConnectProfileProvider.h"
#import "DConnectManager+Private.h"
#import "DConnectServiceListViewController.h"

NSString *const DConnectSystemProfileName = @"system";

NSString *const DConnectSystemProfileInterfaceDevice = @"device";
NSString *const DConnectSystemProfileAttrWakeUp = @"wakeup";
NSString *const DConnectSystemProfileAttrKeyword = @"keyword";
NSString *const DConnectSystemProfileAttrEvents = @"events";

NSString *const DConnectSystemProfileParamSupports = @"supports";
NSString *const DConnectSystemProfileParamPlugins = @"plugins";
NSString *const DConnectSystemProfileParamPluginId = @"pluginId";
NSString *const DConnectSystemProfileParamId = @"id";
NSString *const DConnectSystemProfileParamName = @"name";
NSString *const DConnectSystemProfileParamVersion = @"version";
NSString *const DConnectSystemProfileParamUUID = @"uuid";


@implementation DConnectSystemProfile

- (NSString *) profileName {
    return DConnectSystemProfileName;
}

- (BOOL) didReceivePutWakeupRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewController = [_dataSource profile:self settingPageForRequest:request];
        if (viewController) {
            
            if (viewController && [viewController isKindOfClass: [UINavigationController class]]) {
                UINavigationController *navigationController =(UINavigationController *)viewController;
                
                if ([navigationController.viewControllers count] > 0) {
                    DConnectServiceListViewController *viewController = (DConnectServiceListViewController *)navigationController.viewControllers[0];
                    viewController.delegate = self.delegate;
                }
            }
            
            UIViewController *rootView;
            DCPutPresentedViewController(rootView);
            [rootView presentViewController:viewController animated:YES completion:nil];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        
        [[DConnectManager sharedManager] sendResponse:response];
    });
    
    return NO;
}

#pragma mark - Setter

+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message {
    [message setArray:supports forKey:DConnectSystemProfileParamSupports];
}

+ (void) setPlugins:(DConnectArray *)plugins target:(DConnectMessage *)message {
    [message setArray:plugins forKey:DConnectSystemProfileParamPlugins];
}

+ (void) setId:(NSString *)pluginId target:(DConnectMessage *)message {
    [message setString:pluginId forKey:DConnectSystemProfileParamId];
}

+ (void) setName:(NSString *)name target:(DConnectMessage *)message {
    [message setString:name forKey:DConnectSystemProfileParamName];
}
+ (void) setUUID:(NSString *)uuid target:(DConnectMessage *)message {
    [message setString:uuid forKey:DConnectSystemProfileParamUUID];
}

#pragma mark - Getter Methods

+ (NSString *) pluginIdFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectSystemProfileParamPluginId];
}

@end
