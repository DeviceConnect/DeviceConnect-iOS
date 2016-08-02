//
//  DConnectProfileSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/29.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectSpecConstants.h"
#import "DConnectApiSpec.h"
#import "DConnectProfileSpec.h"

// DConnectProfileSpec # Builder
@interface DConnectProfileSpecBuilder : NSObject

// BundleFactory mFactory;
@property(nonatomic) NSMutableDictionary *bundle;

- (void) addApiSpec: (NSString *) path method: (DConnectSpecMethod) method  apiSpec:(DConnectApiSpec *) apiSpec;
- (DConnectProfileSpec *) build;

@end
