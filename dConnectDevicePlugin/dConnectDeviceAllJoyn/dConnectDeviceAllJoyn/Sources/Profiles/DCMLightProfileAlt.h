//
//  DCMLightProfileAlt.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief Lightプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.7.22)
 */
#import <DConnectSDK/DConnectSDK.h>


@class DCMLightProfileAlt;

/*!
 @brief Light プロファイル。
 <p>
 デバイスのライト機能を提供するAPI。<br/>
 デバイスのライト機能を提供するデバイスプラグインは当クラスを継承し、対応APIを実装すること。 <br/>
 </p>
 */
@protocol DCMLightProfileAltDelegate<NSObject>
@optional

/*!
 @brief デバイスのライトのステータスを取得する.<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 GET http://{ドメイン}/light?serviceId=xxxxx
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)              profile:(DCMLightProfileAlt *)profile
    didReceiveGetLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId;

/*!
 @brief デバイスのライトを点灯する<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 POST http://{ドメイン}/light?serviceId=xxxxx&lightId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] lightId ライトID
 @param[in] brightness 明るさ
 @param[in] color 色
 @param[in] flashing 点滅
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)            profile:(DCMLightProfileAlt *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString *)lightId
                 brightness:(NSNumber *)brightness
                      color:(NSString *)color
                   flashing:(NSArray *)flashing;
/*!
 @brief デバイスのライトのステータスを変更する.<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{ドメイン}/light?serviceId=xxxxx&lightId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] lightId ライトID
 @param[in] name ライト名
 @param[in] brightness 明るさ
 @param[in] color 色
 @param[in] flashing 点滅
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)            profile:(DCMLightProfileAlt *)profile
  didReceivePutLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString *)lightId
                       name:(NSString *)name
                 brightness:(NSNumber *)brightness
                      color:(NSString *)color
                   flashing:(NSArray *)flashing;
/*!
 @brief デバイスのライトを消灯させる<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 DELETE http://{ドメイン}/light?serviceId=xxxxx&lightId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] lightId ライトID
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                 profile:(DCMLightProfileAlt *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                         lightId:(NSString *)lightId;




/*!
 @brief デバイスのライトグループのステータスを取得する.<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 GET http://{ドメイン}/light/group?serviceId=xxxxx
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                profile:(DCMLightProfileAlt *)profile
 didReceiveGetLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId;

/*!
 @brief デバイスのライトグループを点灯する<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 POST http://{ドメイン}/light/group?serviceId=xxxxx&groupId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] groupId ライトグループID
 @param[in] brightness 明るさ
 @param[in] color 色
 @param[in] flashing 点滅
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                profile:(DCMLightProfileAlt *)profile
didReceivePostLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                        groupId:(NSString *)groupId
                     brightness:(NSNumber *)brightness
                          color:(NSString *)color
                       flashing:(NSArray *)flashing;
/*!
 @brief デバイスのライトグループのステータスを変更する.<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{ドメイン}/light/group?serviceId=xxxxx&groupId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] groupId ライトグループID
 @param[in] name ライト名
 @param[in] brightness 明るさ
 @param[in] color 色
 @param[in] flashing 点滅
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                profile:(DCMLightProfileAlt *)profile
 didReceivePutLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                        groupId:(NSString *)groupId
                           name:(NSString *)name
                     brightness:(NSNumber *)brightness
                          color:(NSString *)color
                       flashing:(NSArray *)flashing;
/*!
 @brief デバイスのライトグループを消灯させる<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 DELETE http://{ドメイン}/light/group?serviceId=xxxxx&groupId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] groupId ライトID
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                    profile:(DCMLightProfileAlt *)profile
  didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                            groupId:(NSString *)groupId;

/*!
 @brief デバイスのライトグループを作成<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 POST http://{ドメイン}/light/group/create?serviceId=xxxxx&groupId=yyyy&groupName=bathroom
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] groupId ライトグループID
 @param[in] groupName ライトグループ名
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMLightProfileAlt *)profile
  didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                               lightIds:(NSArray *)lightIds
                              groupName:(NSString *)groupName;

/*!
 @brief デバイスのライトグループを削除する<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 DELETE http://{ドメイン}/light/group/clear?serviceId=xxxxx&groupId=yyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] groupId ライトID
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMLightProfileAlt *)profile
 didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                groupId:(NSString *)groupId;


@end
/*!
 @class DCMLightProfileAlt
 @brief Lightプロファイル。
 
 Light Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMLightProfileAlt : DConnectProfile
/*!
 @brief DCMLightProfileAltのデリゲートオブジェクト。
 
 デリゲートは @link DCMLightProfileAltDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, assign) id<DCMLightProfileAltDelegate> delegate;


@end
