//
//  DConnectApiSpecList.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#import "DConnectApiSpec.h"

@interface DConnectApiSpecList : NSObject

/*!
 @brief DConnectApiSpecListの共有インスタンスを返す。
 @return DConnectApiSpecListの共有インスタンス。
 */
+ (instancetype)shared;

- (DConnectApiSpec *) findApiSpec: (NSString *) method
                             path: (NSString *) path;

- (void) addApiSpecList :(NSString *)profileName;

- (void) addApiSpec : (DConnectApiSpec *)apiSpec;

@end
