//
//  DConnectApiSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpec.h"

/*
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
*/

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


#pragma mark - DConnectApiSpec Other Method



// toBundle()相当
- (NSDictionary *)toDictionary {
    
    // JSON出力用Dictionaryを作成して返す
    @try {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[DConnectApiSpecJsonKeyName] = self.mName;
        dic[DConnectApiSpecJsonKeyType] = [DConnectApiSpec convertTypeToString: self.mType];
        dic[DConnectApiSpecJsonKeyMethod] = [DConnectSpecConstants toMethodString: self.mMethod];
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







@end




