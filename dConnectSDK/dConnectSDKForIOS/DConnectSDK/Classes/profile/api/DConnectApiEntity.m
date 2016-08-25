//
//  DConnectApiEntity.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectApiEntity.h>

@implementation DConnectApiEntity

- (id)copyWithZone:(NSZone *)zone {
    
    DConnectApiEntity *copyInstance = [[DConnectApiEntity alloc] init];
    
    [copyInstance setMethod: [self method]];
    [copyInstance setPath: [NSString stringWithString: [self path]]];
    [copyInstance setApi: [self.api copy]];
    [copyInstance setApiSpec: [self.apiSpec copy]];
    
    return copyInstance;
}

@end
