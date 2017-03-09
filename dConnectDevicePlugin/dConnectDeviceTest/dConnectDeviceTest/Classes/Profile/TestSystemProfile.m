//
//  TestSystemProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestSystemProfile.h"

NSString *const TestSystemVersion = @"2.0.0";

@implementation TestSystemProfile

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.dataSource = self;
        
        // API登録(didReceiveDeleteEventsRequest相当)
        NSString *getVolumeRequestApiPath =
        [self apiPath: DConnectSettingProfileInterfaceSound
        attributeName: DConnectSettingProfileAttrVolume];
        [self addGetPath: getVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        
            response.result = DConnectMessageResultTypeOk;
            return YES;
        }];
    }
    
    return self;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"2.0.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender settingPageForRequest:(DConnectRequestMessage *)request {
    return [UIViewController new];
}

@end
