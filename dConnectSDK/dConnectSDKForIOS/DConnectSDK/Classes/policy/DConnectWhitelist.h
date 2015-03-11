//
//  DConnectWhitelist.h
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectOrigin.h"
#import "DConnectOriginInfo.h"

@interface DConnectWhitelist : NSObject

- (NSArray *) origins;

- (BOOL) allows:(id<DConnectOrigin>) origin;

- (DConnectOriginInfo *) addOrigin:(id<DConnectOrigin>) origin title:(NSString *)title;

- (void) updateOrigin:(DConnectOriginInfo *) info;

- (void) removeOrigin:(DConnectOriginInfo *) info;

@end
