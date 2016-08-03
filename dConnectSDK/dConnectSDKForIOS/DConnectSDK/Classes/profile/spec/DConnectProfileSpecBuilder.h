//
//  DConnectProfileSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpec.h"

@interface DConnectProfileSpecBuilder : NSObject

@property(nonatomic, strong) NSMutableDictionary *allApiSpecs;  // Map<String, Map<Method, DConnectApiSpec>>

@property(nonatomic, strong) NSDictionary *bundle;

- (void) addApiSpec: (NSString *) path method: (DConnectSpecMethod) method apiSpec: (DConnectApiSpec *) apiSpec;

- (DConnectProfileSpec *) build;

@end
