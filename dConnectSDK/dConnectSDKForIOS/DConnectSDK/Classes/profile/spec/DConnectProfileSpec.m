//
//  DConnectProfileSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfileSpec.h"
//#import "DConnectProfileSpecBundleFactory.h"

@implementation DConnectProfileSpec

// List<DConnectApiSpec>
- (NSArray *) apiSpecList {

    // List<DConnectApiSpec>
    NSMutableArray *list = [NSMutableArray array];
    if (![self apiSpecs]) {
        return list;
    }
    // Map<Method, DConnectApiSpec> apiSpecs
    for (NSDictionary *apiSpecs in [[self apiSpecs] allValues]) {
        for (DConnectApiSpec *apiSpec in [apiSpecs allValues]) {
            [list addObject: apiSpec];
        }
    }
    return list;
}

// Map<Method, DConnectApiSpec>
-(NSDictionary *) findApiSpecs: (NSString *) path {
    if (!path) {
        @throw @"path is null.";
    }
    
    return [self apiSpecs][[path lowercaseString]];
}

- (DConnectApiSpec *) findApiSpec: (NSString *)path method: (DConnectSpecMethod) method {
    if (!method) {
        @throw @"method is null.";
    }
    // Map<Method, DConnectApiSpec> apiSpecsOfPath
    NSDictionary *apiSpecsOfPath = [self findApiSpecs: path];
    if (!apiSpecsOfPath) {
        return nil;
    }
    NSString *strMethod = [DConnectSpecConstants toMethodString: method];
    return apiSpecsOfPath[strMethod];
}

// Map<Method, DConnectApiSpec>
- (NSDictionary *) toBundle {
    return [self bundle];
}

@end
