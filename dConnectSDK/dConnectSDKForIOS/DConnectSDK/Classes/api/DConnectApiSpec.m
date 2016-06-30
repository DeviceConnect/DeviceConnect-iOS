//
//  DConnectApiSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpec.h"

NSString * const DConnectApiSpecMethodGet = @"GET";
NSString * const DConnectApiSpecMethodPut = @"PUT";
NSString * const DConnectApiSpecMethodPost = @"POST";
NSString * const DConnectApiSpecMethodDelete = @"DELETE";

NSString * const DConnectApiSpecTypeOneShot = @"one-shot";
NSString * const DConnectApiSpecTypeEvent = @"event";

NSString * const DConnectApiSpecJsonKeyName = @"name";
NSString * const DConnectApiSpecJsonKeyPath = @"path";
NSString * const DConnectApiSpecJsonKeyMethod = @"method";
NSString * const DConnectApiSpecJsonKeyType = @"type";
NSString * const DConnectApiSpecJsonKeyRequestParams = @"requestParams";

@interface DConnectApiSpec()

@property NSString *name;

@property DConnectApiSpecType type;

@property DConnectApiSpecMethod method;

@property NSString *path;

// DConnectRequestParamSpecの配列
@property NSArray *requestParamSpecList;

@end

@implementation DConnectApiSpec

// 初期化
- (id) init {
    self = [super init];
    if (self) {
        
        // 初期値設定
        self.name = @"";
        self.type = ONESHOT;
        self.method = GET;
        self.path = @"";
        self.requestParamSpecList = [NSArray array];
    }
    return self;
}

#pragma mark - DConnectApiSpec Getter Method

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



#pragma mark - DConnectApiSpec Setter Method

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



#pragma mark - DConnectApiSpec Other Method



// toBundle()相当
- (NSDictionary *)toDictionary {
    
    // JSON出力用Dictionaryを作成して返す
    @try {
        NSString *strMethod = [DConnectApiSpec convertMethodToString: self.method];
        NSString *strType = [DConnectApiSpec convertTypeToString: self.type];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject: self.name forKey: DConnectApiSpecJsonKeyName];
        [dic setObject: strMethod forKey: DConnectApiSpecJsonKeyType];
        [dic setObject: strType forKey: DConnectApiSpecJsonKeyMethod];
        [dic setObject: self.path forKey: DConnectApiSpecJsonKeyPath];
        [dic setObject: self.requestParamSpecList forKey: DConnectApiSpecJsonKeyRequestParams];
        return dic;
    }
    @catch (NSException *e) {
        return nil;
    }
}









#pragma mark - DConnectApiSpec Static Method

+ (DConnectApiSpecMethod) parseMethod: (NSString *)string {
    if (string == nil) {
        @throw [NSString stringWithFormat: @"method is invalid : nil"];
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecMethodGet lowercaseString]]) {
        return GET;
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecMethodPut lowercaseString]]) {
        return PUT;
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecMethodPost lowercaseString]]) {
        return POST;
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecMethodDelete lowercaseString]]) {
        return DELETE;
    }
    @throw [NSString stringWithFormat: @"method is invalid : %@", string];
}

+ (DConnectApiSpecType) parseType: (NSString *)string {
    if (string == nil) {
        @throw [NSString stringWithFormat: @"type is invalid : nil"];
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecTypeOneShot lowercaseString]]) {
        return ONESHOT;
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecTypeEvent lowercaseString]]) {
        return EVENT;
    }
    @throw [NSString stringWithFormat: @"type is invalid: %@", string];
}

+ (NSString *) convertMethodToString: (DConnectApiSpecMethod) enMethod {
    
    if (enMethod == GET) {
        return DConnectApiSpecMethodGet;
    }
    if (enMethod == PUT) {
        return DConnectApiSpecMethodPut;
    }
    if (enMethod == POST) {
        return DConnectApiSpecMethodPost;
    }
    if (enMethod == DELETE) {
        return DConnectApiSpecMethodDelete;
    }
    @throw @"unknown enum(method).";
}

+ (NSString *) convertTypeToString: (DConnectApiSpecType) enType {
    
    if (enType == ONESHOT) {
        return DConnectApiSpecTypeOneShot;
    }
    if (enType == EVENT) {
        return DConnectApiSpecTypeEvent;
    }
    @throw @"unknown enum(type).";
}

@end




