//
//  DConnectFileProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectFileProfile.h"


NSString *const DConnectFileProfileName = @"file";
NSString *const DConnectFileProfileAttrList = @"list";
NSString *const DConnectFileProfileParamMIMEType = @"mimeType";
NSString *const DConnectFileProfileParamFiles = @"files";
NSString *const DConnectFileProfileParamFileName = @"fileName";
NSString *const DConnectFileProfileParamFileSize = @"fileSize";
NSString *const DConnectFileProfileParamData = @"data";
NSString *const DConnectFileProfileParamUri = @"uri";
NSString *const DConnectFileProfileParamPath = @"path";
NSString *const DConnectFileProfileParamFileType = @"fileType";
NSString *const DConnectFileProfileParamOrder = @"order";
NSString *const DConnectFileProfileParamOffset = @"offset";
NSString *const DConnectFileProfileParamLimit = @"limit";
NSString *const DConnectFileProfileParamCount = @"count";
NSString *const DConnectFileProfileParamUpdateDate = @"updateDate";

NSString *const DConnectFileProfileOrderASC = @"asc";
NSString *const DConnectFileProfileOrderDESC = @"desc";


@implementation DConnectFileProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectFileProfileName;
}

#pragma mark - Setter

+ (void) setURI:(NSString *)uri target:(DConnectMessage *)message {
    [message setString:uri forKey:DConnectFileProfileParamUri];
}

+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectFileProfileParamMIMEType];
}

+ (void) setFileName:(NSString *)fileName target:(DConnectMessage *)message {
    [message setString:fileName forKey:DConnectFileProfileParamFileName];
}

+ (void) setFileSize:(long long)fileSize target:(DConnectMessage *)message {
    [message setLongLong:fileSize forKey:DConnectFileProfileParamFileSize];
}

+ (void) setFileType:(int)fileType target:(DConnectMessage *)message {
    [message setInteger:fileType forKey:DConnectFileProfileParamFileType];
}

+ (void) setFiles:(DConnectArray *)files target:(DConnectMessage *)message {
    [message setArray:files forKey:DConnectFileProfileParamFiles];
}

+ (void) setPath:(NSString *)path target:(DConnectMessage *)message {
    [message setString:path forKey:DConnectFileProfileParamPath];
}

+ (void) setCount:(int)count target:(DConnectMessage *)message {
    [message setInteger:count forKey:DConnectFileProfileParamCount];
}

+ (void) setUpdateDate:(NSString *)updateDate tareget:(DConnectMessage *)message {
    [message setString:updateDate forKey:DConnectFileProfileParamUpdateDate];
}

#pragma mark - Getter

+ (NSString *) fileNameFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileProfileParamFileName];
}

+ (NSString *) mimeTypeFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileProfileParamMIMEType];
}

+ (NSData *) dataFromRequest:(DConnectMessage *)request {
    return [request dataForKey:DConnectFileProfileParamData];
}

+ (NSString *) uriFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileProfileParamUri];
}

+ (NSString *) pathFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileProfileParamPath];
}

+ (NSString *) orderFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileProfileParamOrder];
}

+ (NSNumber *) offsetFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectFileProfileParamOffset];
}

+ (NSNumber *) limitFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectFileProfileParamLimit];
}


@end
