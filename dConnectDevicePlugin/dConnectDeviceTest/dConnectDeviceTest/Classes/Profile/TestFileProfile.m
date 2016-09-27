//
//  TestFileProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestFileProfile.h"
#import "DeviceTestPlugin.h"

NSString *const TestFileMimeType = @"image/png";
const int TestFileFileSize = 64000;
const int TestFileFileType = 0;
NSString *const TestFileFileName = @"test.png";
NSString *const TestFilePath = @"/test.png";

// イベント送信用のマクロ
#define SELF_PLUGIN ((DeviceTestPlugin *)self.plugin)
#define WEAKSELF_PLUGIN ((DeviceTestPlugin *)weakSelf.plugin)

@interface TestFileProfile()

- (NSString *) fileNameFromPath:(NSString *)path;

@end

@implementation TestFileProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestFileProfile *weakSelf = self;
        
        // API登録(didReceiveGetReceiveRequest相当)
        NSString *getReceiveRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileProfileAttrReceive];
        [self addGetPath: getReceiveRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = request.serviceId;
            NSString *path = [DConnectFileProfile pathFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
                
                NSString *fileName = [weakSelf fileNameFromPath:path];
                
                NSString *uri = [[[[WEAKSELF_PLUGIN fm] URL] URLByAppendingPathComponent:fileName] absoluteString];
                
                [DConnectFileProfile setURI:uri target:response];
                [DConnectFileProfile setMIMEType:TestFileMimeType target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetListRequest相当)
        NSString *getListRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileProfileAttrList];
        [self addGetPath: getListRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = request.serviceId;
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                DConnectArray *files = [DConnectArray array];
                DConnectMessage *file = [DConnectMessage message];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"";
                
                [DConnectFileProfile setFileName:TestFileFileName target:file];
                [DConnectFileProfile setPath:TestFilePath target:file];
                [DConnectFileProfile setMIMEType:TestFileMimeType target:file];
                [DConnectFileProfile setUpdateDate:[formatter stringFromDate:[NSDate date]] tareget:file];
                [DConnectFileProfile setFileSize:TestFileFileSize target:file];
                [DConnectFileProfile setFileType:TestFileFileType target:file];
                
                [files addMessage:file];
                [DConnectFileProfile setFiles:files target:response];
                [DConnectFileProfile setCount:files.count target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePostSendRequest相当)
        NSString *postSendRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileProfileAttrSend];
        [self addPostPath: postSendRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSData *data = [DConnectFileProfile dataFromRequest:request];
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileProfile pathFromRequest:request];
//            NSString *mimeType = [DConnectFileProfile mimeTypeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (path == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                NSString *fileName = [weakSelf fileNameFromPath:path];
                NSString *url = [[WEAKSELF_PLUGIN fm] createFileForPath:fileName contents:data];
                
                if (url) {
                    response.result = DConnectMessageResultTypeOk;
                } else {
                    [response setErrorToUnknown];
                }
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteRemoveRequest相当)
        NSString *deleteRemoveRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectFileProfileAttrRemove];
        [self addDeletePath: deleteRemoveRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *path = [DConnectFileProfile pathFromRequest:request];

            CheckDID(response, serviceId)
            if (path == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                NSString *fileName = [weakSelf fileNameFromPath:path];
                if([[WEAKSELF_PLUGIN fm] removeFileForPath:fileName]) {
                    response.result = DConnectMessageResultTypeOk;
                } else {
                    [response setErrorToUnknownWithMessage:[NSString stringWithFormat:@"Failed to remove file: %@", path]];
                }
            }
            
            return YES;
        }];
    }
    
    return self;
}

#pragma mark - Private

- (NSString *) fileNameFromPath:(NSString *)path {
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    if (!components || components.count == 0) {
        return path;
    }
    
    return (NSString *) components[components.count - 1];
}


@end
