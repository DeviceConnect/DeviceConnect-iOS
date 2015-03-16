//
//  DConnectOrigin.h
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @brief An origin of requests which is sent by applications.
 */
@protocol DConnectOrigin <NSObject>

/*!
 @brief Returns whether the specified origin is same or not.
 @param [in] origin another origin
 @retval YES if the specified origin is same, otherwise NO.
 */
- (BOOL) matches: (id<DConnectOrigin>) origin;

- (NSString *) stringify;

@end
