//
//  TestUniqueTimeoutProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestUniqueTimeoutProfile.h"

#define DCONNECT_RESPONSE_TIMEOUT_SEC 60

NSString *const UniqueTimeoutProfileProfileName = @"timeout";
NSString *const UniqueTimeoutProfileAttributeSync = @"sync";
NSString *const UniqueTimeoutProfileAttributeAsync = @"async";

@implementation TestUniqueTimeoutProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestUniqueTimeoutProfile *weakSelf = self;
        
        // API登録(didReceiveGetRequest相当)
        NSString *getRequestApiPath =
        [self apiPath: nil
        attributeName: UniqueTimeoutProfileAttributeSync];
        [self addGetPath: getRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceivePostRequest相当)
        NSString *postRequestApiPath =
        [self apiPath: nil
        attributeName: UniqueTimeoutProfileAttributeSync];
        [self addPostPath: postRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceivePutRequest相当)
        NSString *putRequestApiPath =
        [self apiPath: nil
        attributeName: UniqueTimeoutProfileAttributeSync];
        [self addPutPath: putRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
        // API登録(didReceiveDeleteRequest相当)
        NSString *deleteRequestApiPath =
        [self apiPath: nil
        attributeName: UniqueTimeoutProfileAttributeSync];
        [self addDeletePath: deleteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            return [weakSelf didReceiveRequestCommon:request response:response];
        }];
        
    }
    
    return self;
}

#pragma mark - DConnect Profile Methods

- (NSString *) profileName {
    return UniqueTimeoutProfileProfileName;
}

/*
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
{
    return [self didReceiveRequestCommon:request response:response];
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
{
    return [self didReceiveRequestCommon:request response:response];
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
{
    return [self didReceiveRequestCommon:request response:response];
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    return [self didReceiveRequestCommon:request response:response];
}
*/

#pragma mark - Private Methods

- (BOOL) didReceiveRequestCommon:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    NSString *interface = request.interface;
    NSString *attribute = request.attribute;
    BOOL send = YES;
    if (interface && attribute) {
        [response setErrorToNotSupportAttribute];
    } else if (attribute)  {
        if ([attribute isEqualToString:UniqueTimeoutProfileAttributeSync]) {
            // 同期処理としてタイムアウト発生.
            [NSThread sleepForTimeInterval:DCONNECT_RESPONSE_TIMEOUT_SEC + 1];
        } else if ([attribute isEqualToString:UniqueTimeoutProfileAttributeAsync]) {
            // 非同期処理としてタイムアウト発生.
            send = NO;
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportAttribute];
    }
    return send;
}

@end
