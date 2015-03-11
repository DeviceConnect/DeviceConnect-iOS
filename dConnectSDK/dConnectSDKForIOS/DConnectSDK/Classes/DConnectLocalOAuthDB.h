//
//  DConnectLocalOAuthDB.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

/*!
 @brief LocalOAuthのデータを格納する。
 */
@interface DConnectAuthData : NSObject
/*! @brief AuthDataのユニークID。 */
@property (nonatomic) int id;
/*! @brief サービスID。 */
@property (nonatomic) NSString *serviceId;
/*! @brief クライアントID。 */
@property (nonatomic) NSString *clientId;
@end


/*!
 @brief Local OAuthのDBを管理するクラス。
 */
@interface DConnectLocalOAuthDB : NSObject

/*!
 @brief DConnectLocalOAuthDBを取得する。
 */
+ (DConnectLocalOAuthDB *) sharedLocalOAuthDB;

/*!
 @brief AuthDataをDBに格納する。
 
 @param[in] serviceId サービスID
 @param[in] clientId クライアントID
 
 @retval YES DBに保存成功した場合
 @retval NO DBに保存失敗した場合
 */
- (BOOL)addAuthDataWithServiceId:(NSString *)serviceId clientId:(NSString *)clientId;

- (DConnectAuthData *)getAuthDataByServiceId:(NSString *)serviceId;
- (BOOL)deleteAuthDataByServiceId:(NSString *)serviceId;

- (BOOL)addAccessToken:(NSString *)accessToken withAuthData:(DConnectAuthData *)data;
- (NSString *)getAccessTokenByAuthData:(DConnectAuthData *)data;
- (BOOL)deleteAccessTokenByAuthData:(DConnectAuthData *)data;
- (BOOL)deleteAccessToken:(NSString *)accessToken;
@end
