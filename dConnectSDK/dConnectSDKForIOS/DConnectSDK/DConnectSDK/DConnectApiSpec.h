//
//  DConnectApiSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectMessage.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import <DConnectSDK/DConnectSpecConstants.h>

/*!
 @class DConnectApiSpec
 @brief Device Connect API仕様。
 */
@interface DConnectApiSpec : NSObject<NSCopying>

/*!
 @brief API種別。
 */
@property(nonatomic) DConnectSpecType type;

/*!
 @brief APIメソッド。
 */
@property(nonatomic) DConnectSpecMethod method;

/*!
 @brief API名。
 */
@property(nonatomic, strong) NSString *apiName;

/*!
 @brief プロファイル名。
 */
@property(nonatomic, strong) NSString *profileName;

/*!
 @brief インターフェース名。
 */
@property(nonatomic, strong) NSString *interfaceName;

/*!
 @brief アトリビュート名。
 */
@property(nonatomic, strong) NSString *attributeName;


/*!
 @brief リクエストパラメータ仕様のリスト。
 
 DConnectParamSpecの配列で表現される。
 */
@property(nonatomic, strong) NSArray *requestParamSpecList;

/*!
 @brief APIのパスを取得する。
 @return APIのパスを示す文字列。
 */
- (NSString *) path;

/*!
 @brief APIのパスを設定する。
 @param[in] path APIのパスを示す文字列。
 */
- (void) setPath: (NSString *) path;

/*!
 @brief アプリケーションからのリクエストを検証する。
 @return リクエストが仕様通りであると判断された場合はYES、そうでない場合はNO
 */
- (BOOL) validate: (DConnectRequestMessage *) request;

@end

