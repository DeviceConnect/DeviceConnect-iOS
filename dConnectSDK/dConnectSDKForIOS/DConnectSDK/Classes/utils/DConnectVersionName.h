//
//  DConnectVersionName.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DConnectVersionName : NSObject

- (instancetype) initWithVersion: (NSArray *) version;
+ (DConnectVersionName *) parse: (NSString *) versionName;
- (NSString *) toString;
- (BOOL) isEqualToVersion: (NSObject *) o;

@end
