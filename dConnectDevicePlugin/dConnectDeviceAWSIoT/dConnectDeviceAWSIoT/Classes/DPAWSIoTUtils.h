//
//  DPAWSIoTUtils.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPAWSIoTUtils : NSObject

// アカウントの設定があるか
+ (BOOL)hasAccount;
// アカウントの設定をクリア
+ (void)clearAccount;
// アカウントを設定
+ (void)setAccount:(NSString*)accessKey secretKey:(NSString*)secretKey region:(NSInteger)region;

// Managerを許可
+ (void)addAllowManager:(NSString*)uuid;
// Managerが許可されているか
+ (BOOL)hasAllowedManager:(NSString*)uuid;
// Managerの許可を解除
+ (void)removeAllowManager:(NSString*)uuid;

// イベント更新間隔を設定
+ (void)setEventSyncInterval:(NSInteger)interval;
// イベント更新間隔を取得
+ (NSInteger)eventSyncInterval;

// ローディング画面表示
+ (void)showLoadingHUD:(UIStoryboard*)storyboard;
// ローディング画面非表示
+ (void)hideLoadingHUD;

// メニュー作成
+ (UIAlertController*)createMenu:(NSArray*)items handler:(void (^)(int index))handler;

// ログイン
+ (void)loginWithHandler:(void (^)(NSError *error))handler;
// HTTP通信
+ (void)sendRequest:(NSDictionary*)request handler:(void (^)(NSData *data, NSError *error))handler;

// Packege名取得
+ (NSString *)packageName;

// AccessTokenを取得
+ (NSString*)accessTokenWithServiceId:(NSString*)serviceId;
// AccessTokenを追加
+ (void)addAccessToken:(NSString*)token serviceId:(NSString*)serviceId;

// アラート表示
+ (void)showAlert:(UIViewController*)vc title:(NSString*)title message:(NSString*)message handler:(void (^)())handler;

@end
