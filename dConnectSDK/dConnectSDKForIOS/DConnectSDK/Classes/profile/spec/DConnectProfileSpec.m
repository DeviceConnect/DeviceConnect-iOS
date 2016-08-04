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

- (NSArray *) apiSpecList {

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

-(NSDictionary *) findApiSpecs: (NSString *) path {
    if (!path) {
        @throw @"path is null.";
    }
    
    
    return [self apiSpecs][[path lowercaseString]];     // Map<Method, DConnectApiSpec>
}

- (DConnectApiSpec *) findApiSpec: (NSString *)path method: (DConnectSpecMethod) method {
    if (!method) {
        @throw @"method is null.";
    }
    
    NSDictionary *apiSpecsOfPath = [self findApiSpecs: path];   // Map<Method, DConnectApiSpec> apiSpecsOfPath
    if (!apiSpecsOfPath) {
        return nil;
    }
    NSString *strMethod = [DConnectSpecConstants toMethodString: method];
    return apiSpecsOfPath[strMethod];
}

- (NSDictionary *) toBundle {
    return [self bundle];
}

@end
