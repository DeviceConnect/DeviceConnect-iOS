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
#import <DConnectSDK/DConnectApiSpec.h>
#import "DConnectProfileSpec.h"

@implementation DConnectProfile {
    
    /**
     * Device Connect API 仕様定義リスト.
     */
    DConnectProfileSpec *mProfileSpec;
    
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

- (NSString *) apiPath : (DConnectRequestMessage *) request {
    return [self apiPath:[request interface] attributeName:[request attribute]];
}

- (NSString *) apiPath : (NSString *) interfaceName attributeName:(NSString *) attributeName {
    
    NSMutableString *path = [NSMutableString string];
    [path appendString: @"/"];
    if (interfaceName) {
        [path appendString: interfaceName];
        [path appendString: @"/"];
    }
    if (attributeName) {
        [path appendString: attributeName];
    }
    return path;
}

- (BOOL) isKnownPath: (DConnectRequestMessage *) request {
    NSString *path = [self apiPath:[request interface] attributeName:[request attribute]];
    if (!mProfileSpec) {
        return NO;
    }
    return [mProfileSpec findApiSpecs: path] != nil;
}

- (BOOL) isKnownMethod: (DConnectRequestMessage *) request {
    
    NSError *error;
    DConnectSpecMethod method;
    if (![DConnectSpecConstants toMethodFromAction:[request action] outMethod:&method error:&error]) {
        DCLogE(@"isKnownMethod error: %@", [error localizedDescription]);
        return NO;
    }
    if (!method) {
        return NO;
    }
    NSString *path = [self apiPath: [request interface] attributeName: [request attribute]];
    if (!mProfileSpec) {
        return NO;
    }
    return [mProfileSpec findApiSpec: path method: method] != nil;
}

/**
 * Device Connect API 仕様定義リストを設定する.
 * @param profileSpec API 仕様定義リスト
 */
- (void) setProfileSpec: (DConnectProfileSpec *) profileSpec {
    mProfileSpec = profileSpec;
}

/**
 * Device Connect API 仕様定義リストを取得する.
 * @return API 仕様定義リスト
 */
- (DConnectProfileSpec *) profileSpec {
    return mProfileSpec;
}



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
        if ([self isKnownPath: request]) {
            if ([self isKnownMethod: request]) {
                [response setErrorToNotSupportAttribute];
            } else {
                [response setErrorToNotSupportAction];
            }
        } else {
            [response setErrorToNotSupportAction];
        }
        return YES;
    }
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
    DConnectApiEntity *apiEntity = [DConnectApiEntity new];
    [apiEntity setMethod: [NSString stringWithString: method]];
    [apiEntity setPath: [NSString stringWithString: path]];
    [apiEntity setApi: [api copy]];
    
    @synchronized(mApis) {
        
        // 同名のメソッドとパスがすでに存在する場合は、削除する
        [self removeApi: apiEntity];

        // APIを追加する
        [mApis addObject: apiEntity];
    }
}

- (NSArray *) apis {
    return mApis;
}

- (DConnectApiEntity *) findApi: (DConnectRequestMessage *) request {
    
    DConnectMessageActionType action = [request action];
    
    NSError *error;
    DConnectSpecMethod method;
    if (![DConnectSpecConstants toMethodFromAction: action outMethod: &method error:&error]) {
        return nil;
    }
    
    if (self.profileSpec && self.profileSpec.api && request.api) {
        if (![self.profileSpec.api.lowercaseString isEqualToString: request.api.lowercaseString]) {
            return nil;
        }
    }
    
    NSString *path = [self apiPath: [request interface] attributeName:[request attribute]];
    return [self findApiWithPath: path method: method];
}

- (DConnectApiEntity *) findApiWithPath: (NSString *) path method: (DConnectSpecMethod) method {

    NSError *error;
    NSString *strMethod = [DConnectSpecConstants toMethodString:method error: &error];
    if (!strMethod) {
        return nil;
    }

    @synchronized(mApis) {
        
        for (DConnectApiEntity *api in mApis) {
            if ([api path] && [path localizedCaseInsensitiveCompare: [api path]] == NSOrderedSame &&
                [api method] && [strMethod localizedCaseInsensitiveCompare:[api method]] == NSOrderedSame) {
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

- (BOOL) hasApi: (NSString *) path method: (DConnectSpecMethod) method {
    return [self findApiWithPath: path method: method] != nil;
}

@end
