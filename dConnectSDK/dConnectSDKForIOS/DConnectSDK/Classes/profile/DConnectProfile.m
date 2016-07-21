//
//  DConnectProfile.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfile.h"
#import "DConnectManager.h"
#import "LocalOAuth2Settings.h"
#import "ApiIdentifier.h"
#import <DConnectSDK/DConnectApiSpecList.h>
#import <DConnectSDK/DConnectApiSpec.h>
#import <DConnectSDK/DConnectApi.h>

@implementation DConnectProfile {
    
//    /*!
//     @brief サポートするAPI(key: ApiIdentifier, value: DConnectApi).
//     */
//    NSMutableDictionary *mApis;
    /*!
     @brief サポートするAPI(DConnectApiEntityの配列).
     */
    NSMutableArray *mApis_;
}


- (instancetype) init {
    self = [super init];
    if (self) {
        mApis_ = [NSMutableArray array];
    }
    return self;
}

//- (NSArray *) apis {
//    
//    // ディープコピーして返す
//    // TODO: DConnectApiにNSCopyingプロトコルを実装する
//    NSArray *list = [[NSArray alloc] initWithArray: [mApis allValues] copyItems: YES];
//    return list;
//}

//- (DConnectApi *) findApi: (DConnectRequestMessage *) request {
//    
//    DConnectMessageActionType action = [request action];
//    
//    DConnectApiSpecMethod method;
//    @try {
//        method = [DConnectApiSpec convertActionToMethod: action];
//    }
//    @catch (NSString *e) {
//        return nil;
//    }
//    NSString *path = [self apiPathWithProfileInterfaceAttribute:[request profile] interfaceName:[request interface] attributeName:[request attribute]];
//    NSLog(@"findApi - pluginId: %@", [request pluginId]);
//    return [self findApiWithPath: path method: method];
//}

//- (DConnectApi *) findApiWithPath: (NSString *) path method: (DConnectApiSpecMethod) method {
//    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:path method: method];
//    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
///***/
//    NSLog(@"findApiWithPath - class: %@", [[self class] description]);
//    NSLog(@"findApiWithPath - profile: %@", [self profileName]);
//    NSLog(@"findApiWithPath - path: %@", path);
//    NSLog(@"findApiWithPath - apiIdentifierString: %@", apiIdentifierString);
//    NSLog(@"findApiWithPath - _mApis count: %d", (int)[mApis count]);
//    for (NSString *apiKey in [mApis allKeys]) {
//        NSLog(@"findApiWithPath - _mApi(key): %@", apiKey);
//    }
//    NSLog(@"findApiWithPath - result: %@", (mApis[apiIdentifierString] ? @"(not nil)":@"(nil)"));
//    /***/
//    return mApis[apiIdentifierString];
//}

//- (void) addApi: (DConnectApi *) api {
//    NSString *path = [self apiPath: api];
//    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:path method:[api method]];
//    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
//    /***/
//    NSLog(@"addApi - class: %@", [[self class] description]);
//    NSLog(@"addApi - profile: %@", [self profileName]);
//    NSLog(@"addApi - apiIdentifierString: %@", apiIdentifierString);
//    /***/
//    mApis[apiIdentifierString] = api;
//    /***/
//    NSLog(@"addApi - _mApis: %@", (mApis ? @"(not nil)" : @"(nil)"));
//    NSLog(@"addApi - _mApis count: %d", (int)[mApis count]);
//    /***/
//}

//- (void) removeApi: (DConnectApi *) api {
//    NSString *apiPath = [self apiPath:api];
//    DConnectApiSpecMethod method = [api method];
//    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:apiPath method:method];
//    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
//    [mApis removeObjectForKey: apiIdentifierString];
//}

// TODO: 削除予定
- (NSString *) apiPath: (DConnectApiEntity *) api {
    return [api path];
}

- (NSString *) apiPathWithProfileInterfaceAttribute : (NSString *) profileName interfaceName: (NSString *) interfaceName attributeName:(NSString *) attributeName {

    NSMutableString *path = [NSMutableString string];
    [path appendString: @"/"];
    [path appendString: profileName];
    if (interfaceName) {
        [path appendString: @"/"];
        [path appendString: interfaceName];
    }
    if (attributeName) {
        [path appendString: @"/"];
        [path appendString: attributeName];
    }
    return path;
}


- (BOOL) isKnownApi: (DConnectRequestMessage *)request {
    DConnectMessageActionType action = [request action];
    DConnectApiSpecMethod method;
    @try {
        method = [DConnectApiSpec convertActionToMethod: action];
    }
    @catch (NSString *e) {
        return NO;
    }
    if (!method) {
        return NO;
    }
    
    NSString *strMethod;
    @try {
        strMethod = [DConnectApiSpec convertMethodToString:method];
    }
    @catch (NSString *e) {
        return NO;
    }
    
    NSString *path = [self apiPathWithProfileInterfaceAttribute:[request attribute] interfaceName:[request interface] attributeName:[request attribute]];
    
    DConnectApiSpecList *apiSpecList = [DConnectApiSpecList shared];
    return [apiSpecList findApiSpec: strMethod path: path] != nil;
}


/*
- (void) setService: (DConnectService *) service {
    _mService = service;
}

- (DConnectService *) service {
    return _mService;
}
*/






- (NSString *) profileName {
    return nil;
}

- (NSString *) displayName {
    return nil;
}

- (NSString *) detail {
    return nil;
}

- (long long) expirePeriod {
    return LocalOAuth2Settings_DEFAULT_TOKEN_EXPIRE_PERIOD / 60;
}

- (BOOL) didReceiveRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response {
    
    DConnectApiEntity *api = [self findApi_: request];
    if (api) {
        DConnectApiSpec *spec = [api apiSpec];
        if (spec && ![spec validate: request]) {
            [response setErrorToInvalidRequestParameter];
            return YES;
        }
        
        return [api api](request, response);
    } else {
        if ([self isKnownApi: request]) {
            [response setErrorToNotSupportAttribute];
        } else {
            [response setErrorToUnknownAttribute];
        }
        return YES;
    }
}


- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    [response setErrorToNotSupportAction];
    return YES;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    [response setErrorToNotSupportAction];
    return  YES;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    [response setErrorToNotSupportAction];
    return YES;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    [response setErrorToNotSupportAction];
    return YES;
}

#pragma mark - Blocks version



- (void) addGetPath:(NSString *)path api:(DConnectApiFunction)api
{
    [self addMethod: @"GET" path: path api: api];
}

- (void) addPostPath:(NSString *)path api:(DConnectApiFunction)api
{
    [self addMethod: @"POST" path: path api: api];
}

- (void) addPutPath:(NSString *)path api:(DConnectApiFunction)api
{
    [self addMethod: @"PUT" path: path api: api];
}

- (void) addDeletePath:(NSString *)path api:(DConnectApiFunction)api
{
    [self addMethod: @"DELETE" path: path api: api];
}

- (void) addMethod:(NSString *)method path:(NSString *)path api:(DConnectApiFunction)api
{
    DConnectApiEntity *entity = [DConnectApiEntity new];
    [entity setMethod: method];
    [entity setPath: path];
    [entity setApi: [api copy]];
    
    @synchronized(mApis_) {
        [mApis_ addObject:entity];
    }
}

- (NSArray *) apis_ {
    
    NSArray *apisCopy;
    @synchronized(mApis_) {
        // ディープコピーして返す
        apisCopy = [[NSArray alloc] initWithArray: mApis_ copyItems: YES];
    }
    return apisCopy;
}

- (DConnectApiEntity *) findApi_: (DConnectRequestMessage *) request {
    
    DConnectMessageActionType action = [request action];
    
    DConnectApiSpecMethod method;
    @try {
        method = [DConnectApiSpec convertActionToMethod: action];
    }
    @catch (NSString *e) {
        return nil;
    }
    
    NSString *path = [self apiPathWithProfileInterfaceAttribute:[request profile] interfaceName:[request interface] attributeName:[request attribute]];
    return [self findApiWithPath_: path method: method];
}

- (DConnectApiEntity *) findApiWithPath_: (NSString *) path method: (DConnectApiSpecMethod) method {

    NSString *strMethod = nil;
    @try {
        strMethod = [DConnectApiSpec convertMethodToString:method];
    }
    @catch (NSString *e) {
        return nil;
    }

    @synchronized(mApis_) {
        
        for (DConnectApiEntity *api in mApis_) {
            if ([api path] && [path localizedCaseInsensitiveCompare: [api path]] == NSOrderedSame &&
                [api method] && [strMethod localizedCaseInsensitiveCompare:[api method]] == NSOrderedSame) {
                /***/
                NSLog(@"findApiWithPath - result: (not nil)");
                /***/
                return api;
            }
        }
    }
    return nil;
}

- (void) removeApi_: (DConnectApiEntity *) apiEntity {
    
    NSString *path = [apiEntity path];
    NSString *strMethod = [apiEntity method];
    
    @synchronized(mApis_) {
        for (int index = [mApis_ count] - 1; index >= 0; index --) {
            DConnectApiEntity *api = mApis_[index];
            
            if ([api path] && [path localizedCaseInsensitiveCompare: [api path]] == NSOrderedSame &&
                [api method] && [strMethod localizedCaseInsensitiveCompare:[api method]] == NSOrderedSame) {
                
                [mApis_ removeObjectAtIndex: index];
            }
        }
    }
}

@end
