//
//  DConnectApiSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#import "DConnectRequestParamSpec.h"


typedef enum {
    ONESHOT = 0,
    EVENT,
} DConnectApiSpecType;

typedef enum {
    GET = 0,
    PUT,
    POST,
    DELETE,
} DConnectApiSpecMethod;






@interface DConnectApiSpec : NSObject

+ (DConnectApiSpecMethod) parseMethod: (NSString *)string;

+ (DConnectApiSpecType) parseType: (NSString *)string;

+ (NSString *) convertMethodToString: (DConnectApiSpecMethod) enMethod;

+ (NSString *) convertTypeToString: (DConnectApiSpecType) enType;

+ (DConnectApiSpec *) fromJson : (NSDictionary *)apiObj;

- (NSString *) name;

- (DConnectApiSpecType) type;

- (DConnectApiSpecMethod) method;

- (NSString *) path;

- (NSArray *) requestParamSpecList;

- (NSDictionary *)toDictionary;


@end

@interface DConnectApiSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;

- (id)type: (DConnectApiSpecType) type;

- (id)method: (DConnectApiSpecMethod) method;

- (id)path: (NSString *) path;

- (id)requestParamSpecList:(NSArray *) requestParamSpecList;

- (DConnectApiSpec *)build;

@end
