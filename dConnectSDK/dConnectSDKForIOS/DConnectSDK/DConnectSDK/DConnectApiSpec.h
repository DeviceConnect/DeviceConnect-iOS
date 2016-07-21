//
//  DConnectApiSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectRequestParamSpec.h>
#import <DConnectSDK/DConnectMessage.h>
#import <DConnectSDK/DConnectRequestMessage.h>

extern NSString * const DConnectApiSpecMethodGet;
extern NSString * const DConnectApiSpecMethodPut;
extern NSString * const DConnectApiSpecMethodPost;
extern NSString * const DConnectApiSpecMethodDelete;

extern NSString * const DConnectApiSpecTypeOneShot;
extern NSString * const DConnectApiSpecTypeEvent;

extern NSString * const DConnectApiSpecJsonKeyName;
extern NSString * const DConnectApiSpecJsonKeyPath;
extern NSString * const DConnectApiSpecJsonKeyMethod;
extern NSString * const DConnectApiSpecJsonKeyType;
extern NSString * const DConnectApiSpecJsonKeyRequestParams;
//extern NSString * const DConnectApiSpecJsonKeyRequestParamSpec;


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






@interface DConnectApiSpec : NSObject<NSCopying>

- (instancetype) init;

- (NSString *) name;

- (DConnectApiSpecType) type;

- (DConnectApiSpecMethod) method;

- (NSString *) path;

- (NSArray *) requestParamSpecList;

- (BOOL) validate: (DConnectRequestMessage *) request;

- (NSDictionary *) toDictionary;

- (NSString *) toJson;

- (void) setName: (NSString *) name;

- (void) setType: (DConnectApiSpecType) type;

- (void) setMethod: (DConnectApiSpecMethod) method;

- (void) setPath: (NSString *) path;

- (void) setRequestParamSpecList: (NSArray *) requestParamSpecList;

+ (DConnectApiSpecMethod) parseMethod: (NSString *)string;

+ (DConnectApiSpecType) parseType: (NSString *)string;

+ (DConnectApiSpecMethod) convertActionToMethod: (DConnectMessageActionType) enMethod;

+ (NSString *) convertMethodToString: (DConnectApiSpecMethod) enMethod;

+ (NSString *) convertTypeToString: (DConnectApiSpecType) enType;

@end

