//
//  DConnectSpecErrorFactory.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSpecErrorFactory.h"

@implementation DConnectSpecErrorFactory

+ (NSError *) createError: (NSString *) errorMessage {
    const int errorCode = 0; // 未使用
    NSDictionary *info = @{NSLocalizedDescriptionKey: errorMessage};
    NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:info];
    return error;
}

@end
