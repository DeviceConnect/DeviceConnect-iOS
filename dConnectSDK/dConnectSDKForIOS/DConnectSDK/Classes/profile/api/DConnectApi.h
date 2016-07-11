//
//  DConnectApi.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

//#import <DConnectSDK/DConnectSDK.h>
#import "DConnectApiSpec.h"
#import "DConnectRequestMessage.h"
#import "DConnectResponseMessage.h"

@protocol DConnectApiDelegate <NSObject>

/*!
 @brief RESPONSEメソッドハンドラー.<br>
 リクエストパラメータに応じてデバイスのサービスを提供し、その結果をレスポンスパラメータに格納する。
 レスポンスパラメータの送信準備が出来た場合は返り値にtrueを指定する事。
 送信準備ができていない場合は、返り値にfalseを指定し、スレッドを立ち上げてそのスレッドで最終的にレスポンスパラメータの送信を行う事。
 
 @param[in] request リクエストパラメータ
 @param[in,out] response レスポンスパラメータ
 @retval レスポンスパラメータを送信するか否か
 */
- (BOOL) onRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *) response;

@end

@interface DConnectApi : NSObject

@property(nonatomic, assign) id<DConnectApiDelegate> delegate;

- (instancetype) initWithMethod: (DConnectApiSpecMethod) method;

/*!
 @brief インターフェース名を取得する.
 @retval インターフェース名
 */
- (NSString *) interface;

/*!
 @brief アトリビュート名を取得する.
 @retval アトリビュート名
 */
- (NSString *) attribute;

/*!
 @brief メソッドを取得する.
 @retval メソッド
 */
- (DConnectApiSpecMethod) method;

/*!
 @brief API仕様を取得する.
 @retval API仕様
 */
- (DConnectApiSpec *) apiSpec;

/*!
 @brief API仕様を設定する.
 @param[in] apiSpec API仕様
 */
- (void) setApiSpec: (DConnectApiSpec *) apiSpec;

/*!
 @brief RESPONSEメソッドハンドラー.<br>
 リクエストパラメータに応じてデバイスのサービスを提供し、その結果をレスポンスパラメータに格納する。
 レスポンスパラメータの送信準備が出来た場合は返り値にYESを指定する事。
 送信準備ができていない場合は、返り値にNOを指定し、スレッドを立ち上げてそのスレッドで最終的にレスポンスパラメータの送信を行う事。
 
 @param[in] request リクエストパラメータ
 @param[in,out] response レスポンスパラメータ
 @retval レスポンスパラメータを送信するか否か
 */
- (BOOL) onRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *) response;

@end
