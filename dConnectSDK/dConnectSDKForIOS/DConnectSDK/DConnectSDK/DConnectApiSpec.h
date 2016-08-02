//
//  DConnectApiSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectMessage.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import "DConnectSpecConstants.h"

// TODO: 削除してDConnectSpecConstants.hで定義された定数に変更する。
/*
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

 */





@interface DConnectApiSpec : NSObject<NSCopying>

@property(nonatomic, strong) NSString *name;

@property(nonatomic) DConnectSpecType type;

@property(nonatomic) DConnectSpecMethod method;

@property(nonatomic, strong) NSString *path;

// DConnectRequestParamSpecの配列
@property(nonatomic, strong) NSArray *requestParamSpecList;


- (instancetype) init;

- (BOOL) validate: (DConnectRequestMessage *) request;

- (NSDictionary *) toDictionary;

- (NSString *) toJson;

@end

