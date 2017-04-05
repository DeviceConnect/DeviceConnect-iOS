//
//  DConnectProfileProvider.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectProfile.h>

/*!
 @class DConnectProfileProvider
 @brief Device Connect プロファイルプロバイダー。
 */
@interface DConnectProfileProvider : NSObject

/*!
 @brief プロファイルリストを取得する.
 
 @return プロファイルマップ
 */
- (NSArray *) profiles;

/*!
 @brief プロファイルマップを取得する.
 
 @param name プロファイル名
 @return プロファイル
 */
- (DConnectProfile *) profileWithName: (NSString *) name;

/*!
 @brief プロファイルを追加する.
 
 @param profile プロファイル
 */
- (void) addProfile: (DConnectProfile *) profile;

/*!
 @brief プロファイルを削除する.
 
 @param profile プロファイル
 */
- (void) removeProfile: (DConnectProfile *) profile;

@end
