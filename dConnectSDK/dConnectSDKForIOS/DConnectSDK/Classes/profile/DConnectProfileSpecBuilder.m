//
//  DConnectProfileSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/29.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectProfileSpecBuilder.h"
#import "DConnectProfileSpec.h"
#import "DConnectApiSpec.h"

@interface DConnectProfileSpecBuilder()

// Map<String, Map<Method, DConnectApiSpec>>
@property(nonatomic, strong) NSMutableDictionary *allApiSpecs;

@end


@implementation DConnectProfileSpecBuilder

- (instancetype) init {

    self = [super init];
    if (self) {
        [self setAllApiSpecs: [NSMutableDictionary dictionary]];
    }
    return self;
}

- (void) addApiSpec: (NSString *) path method: (DConnectApiSpecMethod) method  apiSpec:(DConnectApiSpec *) apiSpec {
    
    NSString *pathKey = [path lowercaseString];
    
    // Map<Method, DConnectApiSpec>
    NSMutableDictionary *apiSpecs = [self allApiSpecs][pathKey];
    if (!apiSpecs) {
        apiSpecs = [[NSMutableDictionary alloc] init];  // HashMap<Method, DConnectApiSpec>
        [self allApiSpecs][pathKey] = apiSpecs;
    }
    NSString *strMethod = [DConnectSpecConstants toMethodString: method];
    apiSpecs[strMethod] = apiSpec;
}

- (DConnectProfileSpec *) build {
    DConnectProfileSpec *profileSpec = [DConnectProfileSpec new];
    [profileSpec setApiSpecs: [self allApiSpecs]];
    [profileSpec setBundle: [self bundle]];
    return profileSpec;
}

@end

