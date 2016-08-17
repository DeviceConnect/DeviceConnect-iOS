//
//  DPLinkingSystemProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingSystemProfile.h"

@implementation DPLinkingSystemProfile {
    NSString *_version;
}

- (instancetype) initWithVersion:(NSString *)version
{
    self = [super init];
    if (self) {
        _version = version;
        
        NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
                                                    attributeName: DConnectSystemProfileAttrWakeUp];
        [self addPutPath: putSettingPageForRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         UIViewController *rootView = [UIApplication sharedApplication].keyWindow.rootViewController;
                         while (rootView.presentedViewController) {
                             rootView = rootView.presentedViewController;
                         }
                         if (rootView) {
                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
                             UIViewController *viewController = [storyboard instantiateInitialViewController];
                             [rootView presentViewController:viewController animated:YES completion:nil];
                         }
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;

                     }];
    }
    return self;
}

+ (instancetype) systemProfileWithVersion:(NSString *)version
{
    return [[DPLinkingSystemProfile alloc] initWithVersion:version];
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile
{
    return _version;
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    return [storyboard instantiateInitialViewController];
}

@end
