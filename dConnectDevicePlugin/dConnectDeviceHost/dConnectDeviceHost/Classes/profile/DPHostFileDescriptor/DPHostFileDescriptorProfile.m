//
//  DPHostFileDescriptorProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <sys/stat.h>
#import <sys/event.h>
#import "DPHostFileDescriptorProfile.h"
#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostDevicePlugin.h"
#import "DPHostUtils.h"
#import "DPHostFileDescriptorContext.h"


@interface DPHostFileDescriptorProfile ()

@property NSMutableDictionary *fileHandleDict;

@end

@implementation DPHostFileDescriptorProfile

- (instancetype)initWithFileManager:(DConnectFileManager *)fileMgr
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _fileHandleDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Get Methods

- (BOOL)         profile:(DConnectFileDescriptorProfile *)profile
didReceiveGetOpenRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
                    path:(NSString *)path
                    flag:(NSString *)flag
{
    if (!path || path.length == 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
        return YES;
    }
    
    // pathが絶対であれ相対であれベースURLに追加する。
    path = [SELF_PLUGIN pathByAppendingPathComponent:path];
    
    if (!flag || flag.length == 0 || !([flag isEqualToString:@"r"] || [flag isEqualToString:@"w"]
                                      || [flag isEqualToString:@"rw"])) {
        [response setErrorToInvalidRequestParameterWithMessage:@"flag must be specified."];
        return YES;
    }
    if (_fileHandleDict[path]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"already open file path."];
        return YES;
    }
    DPHostFileDescriptorContext *fileContext = [DPHostFileDescriptorContext new];
    fileContext.flag = flag;
    NSFileHandle *fileHandle;
    if ([flag isEqualToString:@"r"]) {
        // 読み込みのみ
        
        // ファイルが存在しなければならない。そして存在するとしてもディレクトリであってはならない。
        NSFileManager *sysFileMgr = [NSFileManager defaultManager];
        BOOL isDirectory;
        if (![sysFileMgr fileExistsAtPath:path isDirectory:&isDirectory]) {
            [response setErrorToUnknownWithMessage:@"File does not exist."];
            return YES;
        } else if (isDirectory) {
            [response setErrorToUnknownWithMessage:@"Directory can not be specified."];
            return YES;
        }
        
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    } else if ([flag isEqualToString:@"rw"]) {
        // 読み込みと書き込み
        
        // ディレクトリーであってはならない。
        NSFileManager *sysFileMgr = [NSFileManager defaultManager];
        BOOL isDirectory;
        if ([sysFileMgr fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                [response setErrorToUnknownWithMessage:@"Directory can not be specified."];
                return YES;
            }
        } else {
            // ファイルが無い場合は空ファイルを作成する。
            [sysFileMgr createFileAtPath:path contents:nil attributes:nil];
        }
        
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"flag is invalid"];
        return YES;
    }
    fileContext.fileHandler = fileHandle;
    _fileHandleDict[path] = fileContext;
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

- (BOOL)         profile:(DConnectFileDescriptorProfile *)profile
didReceiveGetReadRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
                    path:(NSString *)path
                  length:(NSNumber *)length
                position:(NSNumber *)position
{
    if (!path || path.length == 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
        return YES;
    }
    
    // pathが絶対であれ相対であれベースURLに追加する。
    path = [SELF_PLUGIN pathByAppendingPathComponent:path];
    NSString *lengthString = [request stringForKey:DConnectFileDescriptorProfileParamLength];
    NSString *positionString = [request stringForKey:DConnectFileDescriptorProfileParamLength];
    if (lengthString && ![DPHostUtils existDigitWithString:lengthString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"length is non-float"];
        return YES;
    }
    if (positionString && ![DPHostUtils existDigitWithString:positionString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"position is non-float"];
        return YES;
    }

    if (!length) {
        [response setErrorToInvalidRequestParameterWithMessage:@"length must be specified."];
        return YES;
    }
    if (length && length < 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"length must be greater than 0."];
        return YES;
    }
    
    if (position && position.intValue < 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"position must be a non-negative value."];
        return YES;
    }
    DPHostFileDescriptorContext *fileContext = _fileHandleDict[path];
    NSFileHandle *fileHandle;
    if ((fileHandle = fileContext.fileHandler)) {
        NSData *data;
        unsigned long long oldOffset = [fileHandle offsetInFile];
        @try {
            if (position) {
                [fileHandle seekToFileOffset:[position unsignedLongLongValue]];
            }
            data = [fileHandle readDataOfLength:[length unsignedIntegerValue]];
        }
        @catch (NSException *exception) {
            [fileHandle seekToFileOffset:oldOffset];
            [response setErrorToUnknownWithMessage:@"Failed to read data."];
            return YES;
        }
        NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:path.pathExtension];
        
        [DConnectFileDescriptorProfile setSize:data.length target:response];
        if (data.length > 0) {
            NSString *dataStr = [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, [data base64EncodedStringWithOptions:0]];
            [DConnectFileDescriptorProfile setFileData:dataStr target:response];
        }
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"The file specified by path is not opened; use File Descriptor Open API first to open it."];
    }
    
    return YES;
}

#pragma mark - Put Methods

- (BOOL)          profile:(DConnectFileDescriptorProfile *)profile
didReceivePutCloseRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                     path:(NSString *)path
{
    if (!path || path.length == 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
        return YES;
    }
    
    // pathが絶対であれ相対であれベースURLに追加する。
    path = [SELF_PLUGIN pathByAppendingPathComponent:path];
    DPHostFileDescriptorContext *fileContext = _fileHandleDict[path];

    if (fileContext) {
        if (fileContext.fileHandler) {
            [fileContext.fileHandler closeFile];
            [_fileHandleDict removeObjectForKey:path];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"The file specified by path is not opened; use File Descriptor Open API first to open it."];
        }
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"The file specified by path is not opened; use File Descriptor Open API first to open it."];
    }
    
    return YES;
}

- (BOOL)          profile:(DConnectFileDescriptorProfile *)profile
didReceivePutWriteRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                     path:(NSString *)path
                    media:(NSData *)media
                 position:(NSNumber *)position
{
    if (!media || media.length == 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"No file data"];
        return YES;
    }
    
    if (!path || path.length == 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
        return YES;
    }

    NSString *positionString = [request stringForKey:DConnectFileDescriptorProfileParamPosition];
    if (positionString && ![DPHostUtils existDigitWithString:positionString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"position is non-float"];
        return YES;
    }

    // pathが絶対であれ相対であれベースURLに追加する。
    path = [SELF_PLUGIN pathByAppendingPathComponent:path];
    
    if (position && position.intValue < 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"position must be a non-negative value."];
        return YES;
    }
    DPHostFileDescriptorContext *fileContext = _fileHandleDict[path];
    if (fileContext) {
        if (fileContext.flag) {
            NSRange range = [fileContext.flag rangeOfString:@"rw"];
            if (range.location != NSNotFound) {
                NSFileHandle *fileHandle;
                if ((fileHandle = fileContext.fileHandler)) {
                    unsigned long long oldOffset = [fileHandle offsetInFile];
                    @try {
                        if (position) {
                            unsigned long long fileLength = [fileHandle seekToEndOfFile];
                            if ([position unsignedLongLongValue] > fileLength) {
                                [fileHandle seekToFileOffset:oldOffset];
                                [response setErrorToUnknownWithMessage:@"position is wrong."];
                            } else {
                                [fileHandle seekToFileOffset:[position unsignedLongLongValue]];
                                [fileHandle writeData:media];
                                [fileHandle seekToFileOffset:[position unsignedLongLongValue]+[media length]];
                                [response setResult:DConnectMessageResultTypeOk];
                            }
                        } else {
                            [fileHandle writeData:media];
                            [fileHandle seekToFileOffset:[media length]];
                            [response setResult:DConnectMessageResultTypeOk];
                        }
                    }
                    @catch (NSException *exception) {
                        [fileHandle seekToFileOffset:oldOffset];
                        [response setErrorToUnknownWithMessage:@"Failed to write data."];
                    }
                } else {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"The file specified by path is not opened; use File Descriptor Open API first to open it."];
                }
            } else {
                [response setErrorToIllegalDeviceStateWithMessage:@"Read mode only"];
            }
        } else {
            [response setErrorToIllegalDeviceStateWithMessage:@"Invalid Flag state"];
        }
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"The file specified by path is not opened; use File Descriptor Open API first to open it."];
    }
    return YES;
}

@end
