//
//  DPAllJoynSystemProfile.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSystemProfile.h"


@interface DPAllJoynSystemProfile () <DConnectSystemProfileDataSource>

@property NSString *const version;

@end


@implementation DPAllJoynSystemProfile

- (instancetype) initWithVersion:(NSString *)version
{
    self = [super init];
    if (self) {
        self.dataSource = self;
        self.version = version;
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


- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile
{
    return _version;
}


- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    UIStoryboard *storyBoard;
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    storyBoard = [UIStoryboard storyboardWithName:@"Storyboard"
                                           bundle:DPAllJoynResourceBundle()];
    //    } else{
    //        storyBoard = [UIStoryboard storyboardWithName:@"HueSetting_iPad" bundle:bundle];
    //    }
    return [storyBoard instantiateInitialViewController];
}

@end
