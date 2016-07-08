//
//  DConnectServiceManager.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceManager.h"
#import "DConnectProfile.h"

@implementation DConnectServiceManager


- (void) setApiSpecDictionary: (DConnectApiSpecList *) dictionary {
    _mApiSpecs = dictionary;
}


#pragma mark - DConnectServiceProvider Implement.

- (void) addService: (DConnectService *) service {
    
    NSString *serviceId = [service serviceId];
    
    NSLog(@"addService: id = %@", serviceId);
    
    if (_mApiSpecs) {
        
        for (DConnectProfile *profile in [service profiles]) {
            for (DConnectApi *api in [profile apis]) {
                NSString *path = [self createPath: [profile profileName] api: api];
                
                NSString *strMethod = [DConnectApiSpec convertMethodToString: [api method]];
                DConnectApiSpec *spec = [_mApiSpecs findApiSpec: strMethod path: path];
                if (spec) {
                    [api setApiSpec: spec];
                }
            }
        }
    }
    
    _mDConnectServices[serviceId] = service;
}

- (void) removeService: (DConnectService *) service {
    NSString *serviceId = [service serviceId];
    [_mDConnectServices removeObjectForKey: serviceId];
}

- (DConnectService *) service: (NSString *) serviceId {
    return _mDConnectServices[serviceId];
}

- (NSArray *) serviceList {
    NSLog(@"getServiceList: %d", (int)[_mDConnectServices count]);
    NSMutableArray *list = [NSMutableArray array];
    [list addObjectsFromArray: [_mDConnectServices allValues]];
    return list;
}

- (void) removeAllServices {
    [_mDConnectServices removeAllObjects];
}

- (BOOL) hasService: (NSString *) serviceId {
    if ([self service: serviceId]) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods.

- (NSString *) createPath: (NSString *) profileName api: (DConnectApi *) api {
    NSString *interfaceName = [api interface];
    NSString *attributeName = [api attribute];
    NSMutableString *path = [NSMutableString string];
    [path appendString: @"/"];
    [path appendString: DConnectMessageDefaultAPI];
    [path appendString: @"/"];
    [path appendString: profileName];
    if (interfaceName) {
        [path appendString: @"/"];
        [path appendString: interfaceName];
    }
    if (attributeName) {
        [path appendString: @"/"];
        [path appendString: attributeName];
    }
    return path;
}

@end
