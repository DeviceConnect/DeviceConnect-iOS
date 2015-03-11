//
//  DConnectOriginInfo.m
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectOriginInfo.h"

@implementation DConnectOriginInfo

- (BOOL) matches:(id<DConnectOrigin>) origin
{
    return [self.origin matches:origin];
}

@end