//
//  DConnectServiceProvider.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/15.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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
