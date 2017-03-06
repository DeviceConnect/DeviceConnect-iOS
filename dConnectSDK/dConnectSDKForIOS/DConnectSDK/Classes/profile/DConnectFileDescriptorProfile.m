//
//  DConnectFileDescriptorProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectFileDescriptorProfile.h"

NSString *const DConnectFileDescriptorProfileName = @"fileDescriptor";
NSString *const DConnectFileDescriptorProfileAttrOpen = @"open";
NSString *const DConnectFileDescriptorProfileAttrClose = @"close";
NSString *const DConnectFileDescriptorProfileAttrRead = @"read";
NSString *const DConnectFileDescriptorProfileAttrWrite = @"write";
NSString *const DConnectFileDescriptorProfileAttrOnWatchFile = @"onwatchfile";
NSString *const DConnectFileDescriptorProfileParamFlag = @"flag";
NSString *const DConnectFileDescriptorProfileParamPosition = @"position";
NSString *const DConnectFileDescriptorProfileParamSize = @"size";
NSString *const DConnectFileDescriptorProfileParamLength = @"length";
NSString *const DConnectFileDescriptorProfileParamFileData = @"fileData";
NSString *const DConnectFileDescriptorProfileParamMedia = @"media";
NSString *const DConnectFileDescriptorProfileParamFile = @"file";
NSString *const DConnectFileDescriptorProfileParamCurr = @"curr";
NSString *const DConnectFileDescriptorProfileParamPrev = @"prev";
NSString *const DConnectFileDescriptorProfileParamUri = @"uri";
NSString *const DConnectFileDescriptorProfileParamPath = @"path";

@implementation DConnectFileDescriptorProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectFileDescriptorProfileName;
}

#pragma mark - Setter
/*!
 <code>curr</code>パラメータを設定する。
 @param curr
 @param message
 */
+ (void) setCurr:(NSString *)curr target:(DConnectMessage *)message {
    [message setString:curr forKey:DConnectFileDescriptorProfileParamCurr];
}

+ (void) setPrev:(NSString *)prev target:(DConnectMessage *)message {
    [message setString:prev forKey:DConnectFileDescriptorProfileParamPrev];
}

+ (void) setSize:(long long)size target:(DConnectMessage *)message {
    [message setLongLong:size forKey:DConnectFileDescriptorProfileParamSize];
}

+ (void) setFileData:(NSString *)fileData target:(DConnectMessage *)message {
    [message setString:fileData forKey:DConnectFileDescriptorProfileParamFileData];
}

+ (void) setPath:(NSString *)path target:(DConnectMessage *)message {
    [message setString:path forKey:DConnectFileDescriptorProfileParamPath];
}

+ (void) setFile:(DConnectMessage *)file target:(DConnectMessage *)message {
    [message setMessage:file forKey:DConnectFileDescriptorProfileParamFile];
}

#pragma mark - Getter

+ (NSString *) flagFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileDescriptorProfileParamFlag];
}

+ (NSNumber *) lengthFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectFileDescriptorProfileParamLength];
}

+ (NSNumber *) positionFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectFileDescriptorProfileParamPosition];
}

+ (NSData *) mediaFromRequest:(DConnectMessage *)request {
    return [request dataForKey:DConnectFileDescriptorProfileParamMedia];
}

+ (NSString *) pathFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectFileDescriptorProfileParamPath];
}

@end
