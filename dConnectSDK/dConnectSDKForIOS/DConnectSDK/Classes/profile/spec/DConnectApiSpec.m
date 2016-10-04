//
//  DConnectApiSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpec.h"
#import "DConnectParameterSpec.h"

@interface DConnectApiSpec()

@property(nonatomic, strong) NSString *path_;

@end

@implementation DConnectApiSpec

// 初期化
- (instancetype) init {
    self = [super init];
    if (self) {
        
        // 初期値設定
        [self setType: ONESHOT];
        [self setMethod: GET];
        [self setPath_: nil];
        [self setProfileName: nil];
        [self setInterfaceName: nil];
        [self setAttributeName: nil];
        [self setRequestParamSpecList: [NSArray array]];
    }
    return self;
}

- (NSString *) path {
    return [self path_];
}

- (void) setPath: (NSString *) path {
    
    [self setPath_: path];
    
    NSArray *array = [path componentsSeparatedByString:@"/"];
    if ([array count] >= 2) {
        [self setProfileName: array[2]];
    }
    if ([array count] == 4) {
        [self setAttributeName: array[3]];
    } else if ([array count] == 5) {
        [self setInterfaceName: array[3]];
        [self setAttributeName: array[4]];
    }
}

- (BOOL) validate: (DConnectRequestMessage *) request {
    for (DConnectParameterSpec *paramSpec in [self requestParamSpecList]) {
        id paramValue = [request objectForKey: [paramSpec name]];
        if (![paramSpec validate: paramValue]) {
            return false;
        }
    }
    return true;
}


#pragma mark - NSCopying Implement.

- (id)copyWithZone:(NSZone *)zone {
    
    DConnectApiSpec *copyInstance = [[DConnectApiSpec alloc] init];
    
    [copyInstance setType:[self type]];
    [copyInstance setMethod: [self method]];
    [copyInstance setPath_: [NSString stringWithString: [self path_]]];
    [copyInstance setProfileName: [NSString stringWithString: [self profileName]]];
    [copyInstance setInterfaceName: [NSString stringWithString: [self interfaceName]]];
    [copyInstance setAttributeName: [NSString stringWithString: [self attributeName]]];
    [copyInstance setRequestParamSpecList: [[NSArray alloc] initWithArray: [self requestParamSpecList] copyItems: YES]];
    
    return copyInstance;
}

@end




