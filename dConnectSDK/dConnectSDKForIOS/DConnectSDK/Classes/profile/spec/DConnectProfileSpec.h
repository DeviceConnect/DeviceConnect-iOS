//
//  DConnectProfileSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
//#import "DConnectProfileSpecBundleFactory.h"
#import "DConnectApiSpec.h"
#import "DConnectApiSpecFilter.h"
#import "DConnectSpecConstants.h"
#import "DConnectProfileSpec.h"

// Bundle BundleFactory # createBundle(final DConnectProfileSpec profileSpec, final DConnectApiSpecFilter filter)
typedef NSDictionary * (^DConnectProfileSpecBundleFactory)(NSDictionary *json, DConnectApiSpecFilter filter);


@interface DConnectProfileSpec : NSObject

// Bundle mBundle;
@property (nonatomic, strong) NSDictionary * bundle;

// Map<String, Map<Method, DConnectApiSpec>> mAllApiSpecs;
@property (nonatomic, strong) NSMutableDictionary * apiSpecs;

// List<DConnectApiSpec> getApiSpecList()
- (NSArray *) apiSpecList;

// Map<Method, DConnectApiSpec> findApiSpecs(final String path)
-(NSDictionary *) findApiSpecs: (NSString *) path;

// DConnectApiSpec findApiSpec(final String path, final Method method)
- (DConnectApiSpec *) findApiSpec: (NSString *)path method: (DConnectSpecMethod) method;

// Bundle toBundle()
- (NSDictionary *) toBundle;

@end


