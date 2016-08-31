//
//  DPAWSIoTController.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DPAWSIoTController : NSObject

// 共有インスタンス
+ (instancetype)sharedManager;

// ManagerUUIDを返す
+ (NSString*)managerUUID;
// ManagerNameを返す
+ (NSString*)managerName;

// Shadowからデバイス情報を取得する
+ (void)fetchManagerInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler;
// Shadowのデバイスの更新情報を購読する
+ (void)subscribeManagerUpdateInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler;
// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler;

// RequestTopic購読
+ (void)subscribeRequest;
// RequestTopic購読解除
+ (void)unsubscribeRequest;


// ログイン
- (void)login;
// マネージャー情報を取得
- (void)fetchManagerInfo;
// MQTTにリクエストを送信
- (BOOL)sendRequestToMQTT:(DConnectRequestMessage *)request code:(u_int32_t)requestCode response:(DConnectResponseMessage *)response;
// MQTTからレスポンスを受診
- (void)receivedResponseFromMQTT:(id)json from:(NSDictionary*)manager uuid:(NSString*)uuid;
// ServiceDiscoveryのRequestを処理
- (BOOL)executeServiceDiscoveryRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response requestCode:(u_int32_t)requestCode;

@end
