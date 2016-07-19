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
    }
    return self;
}

+ (instancetype) systemProfileWithVersion:(NSString *)version
{
    DPLinkingSystemProfile *instance = [self new];
    if (instance) {
        (void)[instance initWithVersion:version];
    }
    return instance;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile
{
    return _version;
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyBoard;
    storyBoard = [UIStoryboard storyboardWithName:@"Linking"
                                           bundle:DPLinkingResourceBundle()];
    return [storyBoard instantiateInitialViewController];
}

@end
