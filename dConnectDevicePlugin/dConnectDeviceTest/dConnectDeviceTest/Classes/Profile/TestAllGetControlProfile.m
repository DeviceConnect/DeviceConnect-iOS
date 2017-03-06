//
//  TestAllGetControlProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "TestAllGetControlProfile.h"


NSString *const AllGetControlProfileProfileName = @"allGetControl";
NSString *const AllGetControlProfileInterfaceTest = @"test";
NSString *const AllGetControlProfileAttributePing = @"ping";
NSString *const AllGetControlProfileParamKey = @"key";

NSString *const AllGetControlProfileValueProfile = @"PROFILE_OK";
NSString *const AllGetControlProfileValueInterface = @"INTERFACE_OK";
NSString *const AllGetControlProfileValueAttribute = @"ATTRIBUTE_OK";

@implementation TestAllGetControlProfile

- (id) init {
    self = [super init];
    
    if (self) {
        
        NSString *allGetControlApiPathProfile = [self apiPath:nil attributeName:nil];
        NSString *allGetControlApiPathProfileAttribute = [self apiPath:nil attributeName:AllGetControlProfileAttributePing];
        NSString *allGetControlApiPathProfileInterfaceAttribute = [self apiPath:AllGetControlProfileInterfaceTest
                                                                  attributeName:AllGetControlProfileAttributePing];
        /* Profile */
        [self addGetPath:allGetControlApiPathProfile api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueProfile
                                                                     response:response];
        }];
        [self addPostPath:allGetControlApiPathProfile api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueProfile
                                                                     response:response];
        }];
        [self addPutPath:allGetControlApiPathProfile api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueProfile
                                                                     response:response];
        }];
        [self addDeletePath:allGetControlApiPathProfile api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueProfile
                                                                     response:response];
        }];
        /* Profile Attribute */
        [self addGetPath:allGetControlApiPathProfileAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueAttribute
                                                                     response:response];
        }];
        [self addPostPath:allGetControlApiPathProfileAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueAttribute
                                                                     response:response];
        }];
        [self addPutPath:allGetControlApiPathProfileAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueAttribute
                                                                     response:response];
        }];
        [self addDeletePath:allGetControlApiPathProfileAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueAttribute
                                                                     response:response];
        }];
        /** Profile Interface Attribute */
        [self addGetPath:allGetControlApiPathProfileInterfaceAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueInterface
                                                                     response:response];
        }];
        [self addPostPath:allGetControlApiPathProfileInterfaceAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueInterface
                                                                     response:response];
        }];
        [self addPutPath:allGetControlApiPathProfileInterfaceAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueInterface
                                                                     response:response];
        }];
        [self addDeletePath:allGetControlApiPathProfileInterfaceAttribute api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [TestAllGetControlProfile setResponseParametersWithMessage:AllGetControlProfileValueInterface
                                                                     response:response];
        }];
    }
    
    return self;
}

#pragma mark - DConnect Profile Methods

- (NSString *) profileName {
    return AllGetControlProfileProfileName;
}

#pragma mark - Private Methods

+ (BOOL) setResponseParametersWithMessage:(NSString*)message
                              response:(DConnectResponseMessage*)response
{
    response.result = DConnectMessageResultTypeOk;
    [response setString:message forKey:AllGetControlProfileParamKey];
    return YES;
}

@end
