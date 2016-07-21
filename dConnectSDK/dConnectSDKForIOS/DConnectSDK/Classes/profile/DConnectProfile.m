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

@implementation DConnectProfile {
    
    /*!
     @brief サポートするAPI(DConnectApiEntityの配列).
     */
    NSMutableArray *mApis;
}


- (instancetype) init {
    self = [super init];
    if (self) {
        mApis = [NSMutableArray array];
    }
    return self;
}


// TODO: 削除予定
- (NSString *) apiPath: (DConnectApiEntity *) api {
    return [api path];
}

- (NSString *) apiPathWithProfile : (NSString *) profileName interfaceName: (NSString *) interfaceName attributeName:(NSString *) attributeName {

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
    
    NSString *path = [self apiPathWithProfile:[request attribute] interfaceName:[request interface] attributeName:[request attribute]];
    
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
    
    DConnectApiEntity *api = [self findApi: request];
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
    [entity setMethod: [NSString stringWithString: method]];
    [entity setPath: [NSString stringWithString: path]];
    [entity setApi: [api copy]];
    
    @synchronized(mApis) {
        [mApis addObject:entity];
    }
}

- (NSArray *) apis {
    
    NSArray *apisCopy;
    @synchronized(mApis) {
        // ディープコピーして返す
        apisCopy = [[NSArray alloc] initWithArray: mApis copyItems: YES];
    }
    return apisCopy;
}

- (DConnectApiEntity *) findApi: (DConnectRequestMessage *) request {
    
    DConnectMessageActionType action = [request action];
    
    DConnectApiSpecMethod method;
    @try {
        method = [DConnectApiSpec convertActionToMethod: action];
    }
    @catch (NSString *e) {
        return nil;
    }
    
    NSString *path = [self apiPathWithProfile:[request profile] interfaceName:[request interface] attributeName:[request attribute]];
    return [self findApiWithPath: path method: method];
}

- (DConnectApiEntity *) findApiWithPath: (NSString *) path method: (DConnectApiSpecMethod) method {

    NSString *strMethod = nil;
    @try {
        strMethod = [DConnectApiSpec convertMethodToString:method];
    }
    @catch (NSString *e) {
        return nil;
    }

    @synchronized(mApis) {
        
        for (DConnectApiEntity *api in mApis) {
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

- (void) removeApi: (DConnectApiEntity *) apiEntity {
    
    NSString *path = [apiEntity path];
    NSString *strMethod = [apiEntity method];
    
    @synchronized(mApis) {
        for (int index = [mApis count] - 1; index >= 0; index --) {
            DConnectApiEntity *api = mApis[index];
            
            if ([api path] && [path localizedCaseInsensitiveCompare: [api path]] == NSOrderedSame &&
                [api method] && [strMethod localizedCaseInsensitiveCompare:[api method]] == NSOrderedSame) {
                
                [mApis removeObjectAtIndex: index];
            }
        }
    }
}

@end
