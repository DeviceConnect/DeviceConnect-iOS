//
//  DConnectLightProfileName.h
//  DCMDevicePluginSDK
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
/*! @brief プロファイル名: light。 */
extern NSString *const DConnectLightProfileName;
/*!
 @brief インターフェイス: group。
 */
extern NSString *const DConnectLightProfileInterfaceGroup;
/*!
 @brief 属性: create。
 */
extern NSString *const DConnectLightProfileAttrCreate;
/*!
 @brief 属性: clear。
 */
extern NSString *const DConnectLightProfileAttrClear;

/*!
 @brief パラメータ: lightId。
 */
extern NSString *const DConnectLightProfileParamLightId;
/*!
 @brief パラメータ: name。
 */
extern NSString *const DConnectLightProfileParamName;
/*!
 @brief パラメータ: color。
 */
extern NSString *const DConnectLightProfileParamColor;
/*!
 @brief パラメータ: brightness。
 */
extern NSString *const DConnectLightProfileParamBrightness;
/*!
 @brief パラメータ: flashing。
 */
extern NSString *const DConnectLightProfileParamFlashing;
/*!
 @brief パラメータ: lights。
 */
extern NSString *const DConnectLightProfileParamLights;
/*!
 @brief パラメータ: on。
 */
extern NSString *const DConnectLightProfileParamOn;
/*!
 @brief パラメータ: config。
 */
extern NSString *const DConnectLightProfileParamConfig;
/*!
 @brief パラメータ: groupId。
 */
extern NSString *const DConnectLightProfileParamGroupId;
/*!
 @brief パラメータ: groups。
 */
extern NSString *const DConnectLightProfileParamLightGroups;
/*!
 @brief パラメータ: lightIds。
 */
extern NSString *const DConnectLightProfileParamLightIds;
/*!
 @brief パラメータ: groupName。
 */
extern NSString *const DConnectLightProfileParamGroupName;


@class DConnectLightProfile;

/*!
 @brief Light プロファイル。
 <p>
 デバイスのライト機能を提供するAPI。<br/>
 デバイスのライト機能を提供するデバイスプラグインは当クラスを継承し、対応APIを実装すること。 <br/>
 </p>
 */
@protocol DConnectLightProfileDelegate<NSObject>
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
- (BOOL)              profile:(DConnectLightProfile *)profile
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
- (BOOL)            profile:(DConnectLightProfile *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                 brightness:(NSNumber*)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing;
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
- (BOOL)            profile:(DConnectLightProfile *)profile
  didReceivePutLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                       name:(NSString*)name
                 brightness:(NSNumber*)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing;
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
- (BOOL)                 profile:(DConnectLightProfile *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
                         lightId:(NSString*)lightId;




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
- (BOOL)                profile:(DConnectLightProfile *)profile
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
- (BOOL)                profile:(DConnectLightProfile *)profile
didReceivePostLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                        groupId:(NSString*)groupId
                     brightness:(NSNumber*)brightness
                          color:(NSString*)color
                       flashing:(NSArray*)flashing;
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
- (BOOL)                profile:(DConnectLightProfile *)profile
 didReceivePutLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                        groupId:(NSString*)groupId
                           name:(NSString*)name
                     brightness:(NSNumber*)brightness
                          color:(NSString*)color
                       flashing:(NSArray*)flashing;
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
- (BOOL)                    profile:(DConnectLightProfile *)profile
  didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                            groupId:(NSString*)groupId;

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
- (BOOL)                        profile:(DConnectLightProfile *)profile
  didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                               lightIds:(NSArray*)lightIds
                              groupName:(NSString*)groupName;

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
- (BOOL)                        profile:(DConnectLightProfile *)profile
 didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                                groupId:(NSString*)groupId;


@end
/*!
 @class DConnectLightProfile
 @brief Lightプロファイル。
 
 Light Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DConnectLightProfile : DConnectProfile
/*!
 @brief DConnectLightProfileのデリゲートオブジェクト。
 
 デリゲートは @link DConnectLightProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, assign) id<DConnectLightProfileDelegate> delegate;

#pragma mark - Setter


/*!
 @brief メッセージにライト一覧を設定する。
 
 @param[in] lights ライト一覧
 @param[in,out] message ライト一覧を格納するメッセージ
 */
+ (void) setLights:(DConnectArray *)lights target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトIDを設定する。
 
 @param[in] lightId ライトID
 @param[in,out] message ライトIDを格納するメッセージ
 */
+ (void) setLightId:(NSString*)lightId target:(DConnectMessage *)message;

/*!
 @brief メッセージにライト名を設定する。
 
 @param[in] lightName ライト名
 @param[in,out] message ライト名を格納するメッセージ
 */
+ (void) setLightName:(NSString*)lightName target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトの点灯状態を設定する。
 
 @param[in] isOn 点灯: YES、 消灯: NO
 @param[in,out] message ライトの点灯状態を格納するメッセージ
 */
+ (void) setLightOn:(BOOL)isOn target:(DConnectMessage *)message ;

/*!
 @brief メッセージにライトの設定情報を設定する。
 
 @param[in] config 設定情報文字列
 @param[in,out] message ライトの設定情報を格納するメッセージ
 */
+ (void) setLightConfig:(NSString*)config target:(DConnectMessage *)message;


/*!
 @brief メッセージにライトグループ一覧を設定する。
 
 @param[in] lightGroups ライトグループ一覧
 @param[in,out] message ライトグループ一覧を格納するメッセージ
 */
+ (void) setLightGroups:(DConnectArray *)lightGroups target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトグループIDを設定する。
 
 @param[in] lightGroupId ライトグループID
 @param[in,out] message ライトグループIDを格納するメッセージ
 */
+ (void) setLightGroupId:(NSString*)lightGroupId target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトグループ名を設定する。
 
 @param[in] lightGroupName ライトグループ名
 @param[in,out] message ライトグループ名を格納するメッセージ
 */
+ (void) setLightGroupName:(NSString*)lightGroupName target:(DConnectMessage *)message;

@end
