//
//  DConnectProfileProvider.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfileProvider.h"

@implementation DConnectProfileProvider

/*!
 @brief プロファイルリストを取得する.
 
 @return プロファイルマップ
 */
- (NSArray *) profiles {
    return nil;
}

/*!
 @brief プロファイルマップを取得する.
 
 @param name プロファイル名
 @return プロファイル
 */
- (DConnectProfile *) profileWithName: (NSString *) name {
    return nil;
}

/*!
 @brief プロファイルを追加する.
 
 @param profile プロファイル
 */
- (void) addProfile: (DConnectProfile *) profile {
    
}

/*!
 @brief プロファイルを削除する.
 
 @param profile プロファイル
 */
- (void) removeProfile: (DConnectProfile *) profile {
    
}

@end
