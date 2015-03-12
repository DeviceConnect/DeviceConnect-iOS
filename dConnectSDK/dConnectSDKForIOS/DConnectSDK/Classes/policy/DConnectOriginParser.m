//
//  DConnectOriginParser.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOriginParser.h"
#import "DConnectWebAppOrigin.h"
#import "DConnectLiteralOrigin.h"

@implementation DConnectOriginParser

+ (id<DConnectOrigin>) parse:(NSString *)originExp
{
    id<DConnectOrigin> origin = [DConnectWebAppOrigin parse:originExp];
    if (origin) {
        return origin;
    }
    return [[DConnectLiteralOrigin alloc] initWithString:originExp];
}

@end