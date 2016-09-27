//
//  TestFileDescriptorProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestFileDescriptorProfile.h"
#import "DeviceTestPlugin.h"

const int TestFileDescriptorFileSize = 64000;
NSString *const TestFileDescriptorPath = @"test.txt";
NSString *const TestFileDescriptorUri = @"test_uri";
NSString *const TestFileDescriptorCurr = @"2014-06-01T00:00:00+0900";
NSString *const TestFileDescriptorPrev = @"2014-06-01T00:00:00+0900";

@implementation TestFileDescriptorProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestFileDescriptorProfile *weakSelf = self;
        
        // API登録(didReceiveGetOpenRequest相当)
        NSString *getOpenRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrOpen];
        [self addGetPath: getOpenRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileDescriptorProfile pathFromRequest:request];
            NSString *flag = [DConnectFileDescriptorProfile flagFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil || flag == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetReadRequest相当)
        NSString *getReadRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrRead];
        [self addGetPath: getReadRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileDescriptorProfile pathFromRequest:request];
            NSNumber *length = [DConnectFileDescriptorProfile lengthFromRequest:request];
            NSNumber *position = [DConnectFileDescriptorProfile positionFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil || length == nil || length < 0 || (position != nil && position < 0)) {
                [response setErrorToInvalidRequestParameter];
            } else {
                
                NSData *data = [NSData data];
                NSString *fileData = [data base64EncodedStringWithOptions:kNilOptions];
                response.result = DConnectMessageResultTypeOk;
                [DConnectFileDescriptorProfile setSize:TestFileDescriptorFileSize target:response];
                [DConnectFileDescriptorProfile setFileData:fileData target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutCloseRequest相当)
        NSString *putCloseRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrClose];
        [self addPutPath: putCloseRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileDescriptorProfile pathFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutWriteRequest相当)
        NSString *putWriteRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrWrite];
        [self addPutPath: putWriteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileDescriptorProfile pathFromRequest:request];
            NSData *media = [DConnectFileDescriptorProfile mediaFromRequest:request];
            NSNumber *position = [DConnectFileDescriptorProfile positionFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil || media == nil || (position != nil && position < 0)) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnWatchFileRequest相当)
        NSString *putOnWatchFileRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrOnWatchFile];
        [self addPutPath: putOnWatchFileRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectFileDescriptorProfileAttrOnWatchFile forKey:DConnectMessageAttribute];
                
                DConnectMessage *file = [DConnectMessage message];
                [DConnectFileDescriptorProfile setFile:file target:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnWatchFileRequest相当)
        NSString *deleteOnWatchFileRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileDescriptorProfileAttrOnWatchFile];
        [self addDeletePath: deleteOnWatchFileRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
    
    }
    
    return self;
}

@end
