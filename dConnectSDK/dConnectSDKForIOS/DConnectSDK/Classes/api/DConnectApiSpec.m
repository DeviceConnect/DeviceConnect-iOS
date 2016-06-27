//
//  DConnectApiSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpec.h"


#define METHOD_GET @"GET"
#define METHOD_PUT @"PUT"
#define METHOD_POST @"POST"
#define METHOD_DELETE @"DELETE"

#define TYPE_ONESHOT @"one_shot"
#define TYPE_EVENT @"event"

#define NAME @"name"
#define PATH @"path"
#define METHOD @"method"
#define TYPE @"type"
#define REQUEST_PARAMS @"requestParams"


@interface DConnectApiSpec()

@property NSString *name;

@property DConnectApiSpecType type;

@property DConnectApiSpecMethod method;

@property NSString *path;

// DConnectRequestParamSpecの配列
@property NSArray *requestParamSpecList;

@end

@implementation DConnectApiSpec



- (NSString *) name {
    return self.name;
}

- (DConnectApiSpecType) type {
    return self.type;
}

- (DConnectApiSpecMethod) method {
    return self.method;
}

- (NSString *) path {
    return self.path;
}

- (NSArray *) requestParamSpecList {
    return self.requestParamSpecList;
}

// toBundle()相当
- (NSDictionary *)toDictionary {
    
    // JSON出力用Dictionaryを作成して返す
    @try {
        NSString *strMethod = [DConnectApiSpec convertMethodToString: self.method];
        NSString *strType = [DConnectApiSpec convertTypeToString: self.type];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject: self.name forKey: @"name"];
        [dic setObject: strMethod forKey: @"type"];
        [dic setObject: strType forKey: @"method"];
        [dic setObject: self.path forKey: @"path"];
        [dic setObject: self.requestParamSpecList forKey: @"requestParamSpec"];
        return dic;
    }
    @catch (NSException *e) {
        return nil;
    }
}

- (void) setName: (NSString *)name {
    self.name = name;
}

- (void) setType: (DConnectApiSpecType) type {
    self.type = type;
}

- (void) setMethod: (DConnectApiSpecMethod) method {
    self.method = method;
}

- (void) setPath: (NSString *)path {
    self.path = path;
}

- (void)setRequestParamSpecList: (NSArray *)requestParamSpecList {
    self.requestParamSpecList = requestParamSpecList;
}











+ (DConnectApiSpecMethod) parseMethod: (NSString *)string {
    if ([[string lowercaseString] isEqualToString: [(METHOD_GET) lowercaseString]]) {
        return GET;
    }
    if ([[string lowercaseString] isEqualToString: [(METHOD_PUT) lowercaseString]]) {
        return PUT;
    }
    if ([[string lowercaseString] isEqualToString: [(METHOD_POST) lowercaseString]]) {
        return POST;
    }
    if ([[string lowercaseString] isEqualToString: [(METHOD_DELETE) lowercaseString]]) {
        return DELETE;
    }
    @throw [NSString stringWithFormat: @"method is invalid : %@", string];
}

+ (DConnectApiSpecType) parseType: (NSString *)string {
    if ([[string lowercaseString] isEqualToString: [(TYPE_ONESHOT) lowercaseString]]) {
        return ONESHOT;
    }
    if ([[string lowercaseString] isEqualToString: [(TYPE_EVENT) lowercaseString]]) {
        return EVENT;
    }
    @throw [NSString stringWithFormat: @"type is invalid: %@", string];
}

+ (NSString *) convertMethodToString: (DConnectApiSpecMethod) enMethod {
    
    if (enMethod == GET) {
        return METHOD_GET;
    }
    if (enMethod == PUT) {
        return METHOD_PUT;
    }
    if (enMethod == POST) {
        return METHOD_POST;
    }
    if (enMethod == DELETE) {
        return METHOD_DELETE;
    }
    @throw @"unknown enum(method).";
}

+ (NSString *) convertTypeToString: (DConnectApiSpecType) enType {
    
    if (enType == ONESHOT) {
        return TYPE_ONESHOT;
    }
    if (enType == EVENT) {
        return TYPE_EVENT;
    }
    @throw @"unknown enum(type).";
}

@end



@interface DConnectApiSpecBuilder()

@property NSString *mName;

@property DConnectApiSpecType mType;

@property DConnectApiSpecMethod mMethod;

@property NSString *mPath;

// DConnectRequestParamSpecの配列
@property NSArray *mRequestParamSpecList;

@end

@implementation DConnectApiSpecBuilder

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.mName = nil;
        self.mType = GET;
        self.mMethod = ONESHOT;
        self.mPath = nil;
        self.mRequestParamSpecList = nil;
    }
    
    return self;
}

- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)type: (DConnectApiSpecType)type {
    self.mType = type;
    return self;
}

- (id)method: (DConnectApiSpecMethod)method {
    self.mMethod = method;
    return self;
}

- (id)path: (NSString *)path {
    self.mPath = path;
    return self;
}

- (id)requestParamSpecList: (NSArray *)requestParamSpecList {
    self.mRequestParamSpecList = requestParamSpecList;
    return self;
}

- (DConnectApiSpec *) build {
    DConnectApiSpec *apiSpec = [[DConnectApiSpec alloc] init];
    [apiSpec setName: self.mName];
    [apiSpec setType: self.mType];
    [apiSpec setMethod: self.mMethod];
    [apiSpec setPath: self.mPath];
    [apiSpec setRequestParamSpecList: self.mRequestParamSpecList];
    return apiSpec;
}

+ (DConnectApiSpec *) fromJson : (NSDictionary *)apiObj {
    
    NSLog(@"DConnectApiSpec fromJson start");
    
    NSString *name = [apiObj objectForKey:NAME];
    NSString *path = [apiObj objectForKey:PATH];
    NSString *methodStr = [apiObj objectForKey:METHOD];
    NSString *typeStr = [apiObj objectForKey:TYPE];
    
    @try {
        // 認識できない文字列を渡したら例外をスローする
        DConnectApiSpecMethod method = [DConnectApiSpec parseMethod: methodStr];
        
        // 認識できない文字列を渡したら例外をスローする
        DConnectApiSpecType type = [DConnectApiSpec parseType: typeStr];
        
        //
        NSMutableArray *paramList = [NSMutableArray array]; // DConnectRequestParamSpecの配列
        NSArray *requestParams = [apiObj objectForKey: REQUEST_PARAMS]; // NSDictionaryの配列
        if (requestParams != nil) {
            for (int k = 0; k < [requestParams count]; k ++) {
                NSDictionary *paramObj = [requestParams objectAtIndex: k];
                DConnectRequestParamSpec *paramSpec = [DConnectRequestParamSpec fromJson: paramObj];
                [paramList addObject: paramSpec];
            }
        }
        DConnectApiSpecBuilder *builder = [[DConnectApiSpecBuilder alloc] init];
        
        DConnectApiSpec *apiSpec = [[[[[[builder name: name] type: type] method: method] path: path] requestParamSpecList: paramList] build];
        return apiSpec;
    }
    @catch (NSException *e) {
        DCLogE(@"fromJson exception: %@", e);
        return nil;
    }
}

@end
