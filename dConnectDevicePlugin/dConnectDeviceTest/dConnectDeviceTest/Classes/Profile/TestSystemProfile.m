//
//  TestSystemProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestSystemProfile.h"

NSString *const TestSystemVersion = @"1.0";

@implementation TestSystemProfile

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    
    return self;
}


#pragma mark - DConnectSystemProfileDelegate

#pragma mark - Delete Methods

- (BOOL) profile:(DConnectSystemProfile *)profile didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response sessionKey:(NSString *)sessionKey
{
    response.result = DConnectMessageResultTypeOk;
    return YES;
}

#pragma mark - DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return @"1.0";
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender settingPageForRequest:(DConnectRequestMessage *)request {
    return [UIViewController new];
}

@end
