//
//  DConnectProfileSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfileSpec.h"

@implementation DConnectProfileSpec

- (NSArray *) apiSpecList {

    NSMutableArray *list = [NSMutableArray array];
    if (![self allApiSpecs]) {
        return list;
    }
    // Map<Method, DConnectApiSpec> apiSpecs
    for (NSDictionary *apiSpecs in [[self allApiSpecs] allValues]) {
        for (DConnectApiSpec *apiSpec in [apiSpecs allValues]) {
            [list addObject: apiSpec];
        }
    }
    return list;
}

-(NSDictionary *) findApiSpecs: (NSString *) path {
    if (!path) {
        //@throw @"path is null.";
        return nil;
    }
    return [self allApiSpecs][[path lowercaseString]];     // Map<Method, DConnectApiSpec>
}

- (DConnectApiSpec *) findApiSpec: (NSString *)path method: (DConnectSpecMethod) method {
    NSDictionary *apiSpecsOfPath = [self findApiSpecs: path];   // Map<Method, DConnectApiSpec> apiSpecsOfPath
    if (!apiSpecsOfPath) {
        return nil;
    }
    NSError *error;
    NSString *strMethod = [DConnectSpecConstants toMethodString: method error: &error];
    if (!strMethod) {
        return nil;
    }
    return apiSpecsOfPath[strMethod];
}

- (NSDictionary *) toBundle {
    return [self bundle];
}

#pragma mark - NSCopying Implement.

- (id)copyWithZone:(NSZone *)zone {
    
    DConnectProfileSpec *profileSpec = [[DConnectProfileSpec alloc] init];
    
    [profileSpec setBundle: [self bundle]];
    
    CFPropertyListRef *deepCopyApiSpecs_ = (CFPropertyListRef *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                                      (CFDictionaryRef)[self allApiSpecs],
                                                                                      kCFPropertyListMutableContainersAndLeaves);
    NSMutableDictionary *deepCopyApiSpecs = CFBridgingRelease(deepCopyApiSpecs_);
    [profileSpec setAllApiSpecs: deepCopyApiSpecs];
    
    return profileSpec;
}

@end
