//
//  DConnectOriginInfo.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOriginInfo.h"

@implementation DConnectOriginInfo

- (BOOL) matches:(id<DConnectOrigin>) origin
{
    return [self.origin matches:origin];
}

@end