//
//  DConnectTestCase.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectTestCase.h"

@implementation DConnectTestCase

- (void)setUp
{
    [super setUp];
    self.clientId = @"test_client";
    [self startDConnectManager];
}

- (void)startDConnectManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DConnectManager *mgr = [DConnectManager sharedManager];
        mgr.settings.useLocalOAuth = NO;
        mgr.settings.useOriginEnable = NO;
        [mgr start];
    });
}

- (void) createClientWithCompletion:(void (^)(NSArray *client))completion
{
    // Implement override
}



@end
