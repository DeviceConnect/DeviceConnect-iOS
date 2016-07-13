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

@implementation DConnectProfile


- (NSArray *) apis {
    
    // ディープコピーして返す
    // TODO: DConnectApiにNSCopyingプロトコルを実装する
    NSArray *list = [[NSArray alloc] initWithArray: [_mApis allValues] copyItems: YES];
    return list;
}

- (DConnectApi *) findApi: (DConnectRequestMessage *) request {
    
    DConnectMessageActionType action = [request action];
    
    DConnectApiSpecMethod method;
    @try {
        method = [DConnectApiSpec convertActionToMethod: action];
    }
    @catch (NSString *e) {
        return nil;
    }
    NSString *path = [self apiPathWithProfileInterfaceAttribute:[request profile] interfaceName:[request interface] attributeName:[request attribute]];
    return [self findApiWithPath: path method: method];
}

- (DConnectApi *) findApiWithPath: (NSString *) path method: (DConnectApiSpecMethod) method {
    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:path method: method];
    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
    return _mApis[apiIdentifierString];
}

- (void) addApi: (DConnectApi *) api {
    NSString *path = [self apiPath: api];
    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:path method:[api method]];
    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
    self.mApis[apiIdentifierString] = api;
}

- (void) removeApi: (DConnectApi *) api {
    NSString *apiPath = [self apiPath:api];
    DConnectApiSpecMethod method = [api method];
    ApiIdentifier *apiIdentifier = [[ApiIdentifier alloc] initWithPath:apiPath method:method];
    NSString *apiIdentifierString = [apiIdentifier apiIdentifierString];
    [self.mApis removeObjectForKey: apiIdentifierString];
}

- (NSString *) apiPath: (DConnectApi *) api {
    
    NSString *apiPath = [self apiPathWithProfileInterfaceAttribute: [self profileName]
                         interfaceName:[api interface]
                                                     attributeName:[api attribute]];
    return apiPath;
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
    
    DConnectApi *api = [self findApi: request];
    if (api) {
        DConnectApiSpec *spec = [api apiSpec];
        if (spec && ![spec validate: request]) {
            [response setErrorToInvalidRequestParameter];
            return YES;
        }
        return [api onRequest:request response: response];
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

@end
