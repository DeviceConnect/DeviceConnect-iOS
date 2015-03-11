//
//  DConnectOriginParser.m
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/11.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
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