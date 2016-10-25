//
//  DPAWSIoTController.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPAWSIoTDevicePlugin.h"

@interface DPAWSIoTController : NSObject

@property (nonatomic, weak) DPAWSIoTDevicePlugin *plugin;

// 共有インスタンス
+ (instancetype)sharedManager;

// ManagerUUIDを返す
+ (NSString*)managerUUID;

// ManagerNameを返す
+ (NSString*)managerName;

// Shadowからデバイス情報を取得する
+ (void)fetchManagerInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler;

// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler;

// Topicを作成
+ (NSString*)myTopic:(NSString*)type;

// ログイン
- (void)login;

// ログアウト
- (void)logout;

// マネージャー情報を取得
- (void)fetchManagerInfo;

// MQTTにリクエストを送信
- (BOOL)sendRequestToMQTT:(DConnectRequestMessage *)request code:(u_int32_t)requestCode response:(DConnectResponseMessage *)response;

// ServiceDiscoveryのRequestを処理
- (BOOL)executeServiceDiscoveryRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response requestCode:(u_int32_t)requestCode;

// Eventを発行
- (void)publishEvent:(NSString*)msg key:(NSString*)key;

// WebSocketを開く
- (void) openWebSocket:(NSString*)accessToken;

@end
