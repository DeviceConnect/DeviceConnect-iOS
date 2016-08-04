//
//  DConnectServiceProvider.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceProvider.h"

@implementation DConnectServiceProvider

- (BOOL) hasService: (NSString *) serviceId {
    return NO;
}

- (DConnectService *) service: (NSString *) serviceId {
    return nil;
}

- (NSArray *) services {
    return nil;
}

- (void) addService: (DConnectService *) service {
    return;
}

- (void) removeService: (DConnectService *) service {
    return;
}

- (void) removeAllServices {
    return;
}

@end
