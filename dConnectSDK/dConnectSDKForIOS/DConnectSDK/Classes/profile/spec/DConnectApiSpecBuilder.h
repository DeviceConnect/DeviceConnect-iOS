//
//  DConnectApiSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectApiSpec.h"

@interface DConnectApiSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;

- (id)type: (DConnectApiSpecType) type;

- (id)method: (DConnectApiSpecMethod) method;

- (id)path: (NSString *) path;

- (id)requestParamSpecList:(NSArray *) requestParamSpecList;

- (DConnectApiSpec *)build;


@end
