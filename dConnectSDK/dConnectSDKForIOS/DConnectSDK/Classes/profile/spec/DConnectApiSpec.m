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

@property NSString *mName;

@property DConnectApiSpecType mType;

@property DConnectApiSpecMethod mMethod;

@property NSString *mPath;

// DConnectRequestParamSpecの配列
@property NSArray *mRequestParamSpecList;

@end

@implementation DConnectApiSpec

// 初期化
- (instancetype) init {
    self = [super init];
    if (self) {
        
        // 初期値設定
        self.mName = nil;
        self.mType = ONESHOT;
        self.mMethod = GET;
        self.mPath = nil;
        self.mRequestParamSpecList = [NSArray array];
    }
    return self;
}

#pragma mark - NSCopying Implement.

- (id)copyWithZone:(NSZone *)zone {
    
    DConnectApiSpec *copyInstance = [[DConnectApiSpec alloc] init];
    
    copyInstance.mName = [NSString stringWithString: [self mName]];
    copyInstance.mType = [self mType];
    copyInstance.mMethod = [self mMethod];
    copyInstance.mPath = [NSString stringWithString: [self mPath]];
    copyInstance.mRequestParamSpecList = [[NSArray alloc] initWithArray: [self mRequestParamSpecList] copyItems: YES];
    
    return copyInstance;
}

#pragma mark - DConnectApiSpec Getter Method

- (NSString *) name {
    return self.mName;
}

- (DConnectApiSpecType) type {
    return self.mType;
}

- (DConnectApiSpecMethod) method {
    return self.mMethod;
}

- (NSString *) path {
    return self.mPath;
}

- (NSArray *) requestParamSpecList {
    return self.mRequestParamSpecList;
}

- (BOOL) validate: (DConnectRequestMessage *) request {

    // TODO: validate処理が未実装(iOSではApiIdentifierで照合する？Swagger対応と一緒に作業する)
    for (DConnectRequestParamSpec *paramSpec in [self requestParamSpecList]) {
        
        NSLog(@"paramSpec name : %@", [paramSpec name]);
    }
    return YES;
    
/*
    Bundle extras = request.getExtras();
    for (DConnectRequestParamSpec paramSpec : getRequestParamList()) {
        Object paramValue = extras.get(paramSpec.getName());
        if (!paramSpec.validate(paramValue)) {
            return false;
        }
    }
    return true;
*/
}


#pragma mark - DConnectApiSpec Setter Method

- (void) setName: (NSString *)name {
    self.mName = name;
}

- (void) setType: (DConnectApiSpecType) type {
    self.mType = type;
}

- (void) setMethod: (DConnectApiSpecMethod) method {
    self.mMethod = method;
}

- (void) setPath: (NSString *)path {
    self.mPath = path;
}

- (void)setRequestParamSpecList: (NSArray *)requestParamSpecList {
    self.mRequestParamSpecList = requestParamSpecList;
}



#pragma mark - DConnectApiSpec Other Method



// toBundle()相当
- (NSDictionary *)toDictionary {
    
    // JSON出力用Dictionaryを作成して返す
    @try {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[DConnectApiSpecJsonKeyName] = self.mName;
        dic[DConnectApiSpecJsonKeyType] = [DConnectApiSpec convertTypeToString: self.mType];
        dic[DConnectApiSpecJsonKeyMethod] = [DConnectApiSpec convertMethodToString: self.mMethod];
        dic[DConnectApiSpecJsonKeyPath] = self.mPath;
        
        NSMutableArray *requestParamSpecJsonArray = [NSMutableArray array];
        for (id<DConnectRequestParamSpecDelegate> delegate in self.mRequestParamSpecList) {
            [requestParamSpecJsonArray addObject:[delegate toDictionary]];
        }
        
        
        dic[DConnectApiSpecJsonKeyRequestParams] = requestParamSpecJsonArray;
        
        return dic;
    }
    @catch (NSException *e) {
        return nil;
    }
}

- (NSString *) toJson {
    
    NSDictionary *jsonDict = [self toDictionary];
    
    NSError*error = nil;
    NSData*data = [NSJSONSerialization dataWithJSONObject:jsonDict options:2 error:&error];
    NSString *strJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"DConnectApiSpec # toJson: %@", strJson);
    return strJson;
}








#pragma mark - DConnectApiSpec Static Method

+ (DConnectApiSpecMethod) parseMethod: (NSString *)string {
    if (string == nil) {
        @throw [NSString stringWithFormat: @"apiSpecMethod is invalid : nil"];
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
    @throw [NSString stringWithFormat: @"apiSpecMethod is invalid : %@", string];
}

+ (DConnectApiSpecType) parseType: (NSString *)string {
    if (string == nil) {
        @throw [NSString stringWithFormat: @"apiSpectype is invalid : nil"];
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecTypeOneShot lowercaseString]]) {
        return ONESHOT;
    }
    if ([[string lowercaseString] isEqualToString: [DConnectApiSpecTypeEvent lowercaseString]]) {
        return EVENT;
    }
    @throw [NSString stringWithFormat: @"apiSpectype is invalid: %@", string];
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
    @throw [NSString stringWithFormat: @"unknown ApiSpecMethod : %d", (int)enMethod];
}

+ (DConnectApiSpecMethod) convertActionToMethod: (DConnectMessageActionType) enMethod {

    if (enMethod == DConnectMessageActionTypeGet) {
        return GET;
    }
    if (enMethod == DConnectMessageActionTypePut) {
        return PUT;
    }
    if (enMethod == DConnectMessageActionTypePost) {
        return POST;
    }
    if (enMethod == DConnectMessageActionTypeDelete) {
        return DELETE;
    }
    @throw [NSString stringWithFormat: @"unknown DConnectMessageActionType : %d", (int)enMethod];
}

+ (NSString *) convertTypeToString: (DConnectApiSpecType) enType {
    
    if (enType == ONESHOT) {
        return DConnectApiSpecTypeOneShot;
    }
    if (enType == EVENT) {
        return DConnectApiSpecTypeEvent;
    }
    @throw [NSString stringWithFormat: @"unknown ApiSpecType : %d", (int)enType];
}

@end




