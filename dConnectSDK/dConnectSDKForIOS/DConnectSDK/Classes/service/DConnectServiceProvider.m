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

- (id) plugin {
    return nil;
}

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
    [self addService: service bundle:nil];
}

- (void) addService: (DConnectService *) service bundle:(NSBundle *) selfBundle {
    
}

- (void) removeService: (DConnectService *) service {
    return;
}

- (void) onStatusChange: (DConnectService *) service {
    return;
}

- (void) removeAllServices {
    return;
}

- (void) addServiceListener: (id<DConnectServiceListener>) listener {
    
}

- (void) removeServiceListener: (id<DConnectServiceListener>) listener {
    
}

@end
