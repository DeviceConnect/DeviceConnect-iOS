//
//  DConnectWhitelist.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOrigin.h"
#import "DConnectOriginInfo.h"

@interface DConnectWhitelist : NSObject

+ (DConnectWhitelist *) sharedWhitelist;

- (NSArray *) origins;

- (BOOL) allows:(id<DConnectOrigin>) origin;

- (DConnectOriginInfo *) addOrigin:(id<DConnectOrigin>) origin title:(NSString *)title;

- (void) updateOrigin:(DConnectOriginInfo *) info;

- (void) removeOrigin:(DConnectOriginInfo *) info;

@end
