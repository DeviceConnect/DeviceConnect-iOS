//
//  TestUniquePingProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestUniquePingProfile.h"

NSString *const UniquePingProfileProfileName = @"ping";
NSString *const UniquePingProfileInterfacePing = @"ping";
NSString *const UniquePingProfileAttributePing = @"ping";
NSString *const UniquePingProfileParamPath = @"path";

@implementation TestUniquePingProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestUniquePingProfile *weakSelf = self;
        
        // API登録(didReceiveGetRequest相当)
        NSString *getRequestApiPath =
        [self apiPath: UniquePingProfileInterfacePing
        attributeName: UniquePingProfileAttributePing];
        [self addGetPath: getRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceivePostRequest相当)
        NSString *postRequestApiPath =
        [self apiPath: UniquePingProfileInterfacePing
        attributeName: UniquePingProfileAttributePing];
        [self addPostPath: postRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceivePutRequest相当)
        NSString *putRequestApiPath =
        [self apiPath: UniquePingProfileInterfacePing
        attributeName: UniquePingProfileAttributePing];
        [self addPutPath: putRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceiveDeleteRequest相当)
        NSString *deleteRequestApiPath =
        [self apiPath: UniquePingProfileInterfacePing
        attributeName: UniquePingProfileAttributePing];
        [self addDeletePath: deleteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
    }
    
    return self;
}

#pragma mark - DConnect Profile Methods

- (NSString *) profileName {
    return UniquePingProfileProfileName;
}

#pragma mark - Private Methods

- (BOOL) didReceiveRequestCommon:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
{
    NSString *interface = request.interface;
    NSString *attribute = request.attribute;
    if (interface && attribute) {
        if ([interface isEqualToString:UniquePingProfileInterfacePing] &&
            [attribute isEqualToString:UniquePingProfileAttributePing]) {
            [TestUniquePingProfile setResponseParametersWithPath:@"/ping/ping/ping" response:response reqeust:request];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else if (attribute)  {
        if ([attribute isEqualToString:UniquePingProfileAttributePing]) {
            [TestUniquePingProfile setResponseParametersWithPath:@"/ping/ping" response:response reqeust:request];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [TestUniquePingProfile setResponseParametersWithPath:@"/ping" response:response reqeust:request];
    }
    return YES;
}

+ (void) setResponseParametersWithPath:(NSString*)path
                              response:(DConnectResponseMessage*)response
                               reqeust:(DConnectRequestMessage*)request
{
    response.result = DConnectMessageResultTypeOk;
    [TestUniquePingProfile setPingPath:path target:response];
    [TestUniquePingProfile copyStringsWithReqeust:request target:response];
}

+ (void) setPingPath:(NSString *)path target:(DConnectResponseMessage*)target
{
    [target setString:path forKey:UniquePingProfileParamPath];
}

+ (void) copyStringsWithReqeust:(DConnectRequestMessage*)request target:(DConnectResponseMessage*)target
{
    for (NSString *key in [request allKeys]) {
        // 以下の特別なパラメータはコピーしない.
        if ([key isEqualToString:DConnectMessageServiceId]
            || [key isEqualToString:DConnectMessagePluginId]
            || [key isEqualToString:DConnectMessageAccessToken]
            || [key isEqualToString:DConnectMessageAccessToken]
            || [key isEqualToString:DConnectMessageProfile]
            || [key isEqualToString:DConnectMessageInterface]
            || [key isEqualToString:DConnectMessageAttribute]
            || [key isEqualToString:DConnectMessageAction]
            || [key isEqualToString:DConnectMessageResult]
            || [key isEqualToString:DConnectMessageErrorCode]
            || [key isEqualToString:DConnectMessageErrorMessage])
        {
            continue;
        }
        [target setString:[request objectForKey:key] forKey:key];
    }
}

@end
