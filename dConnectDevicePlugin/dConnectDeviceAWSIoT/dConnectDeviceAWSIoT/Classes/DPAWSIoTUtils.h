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
+ (void)sendRequestDictionary:(NSDictionary*)requestDic callback:(DConnectResponseBlocks)callback;

// Packege名取得
+ (NSString *)packageName;

// アラート表示
+ (void)showAlert:(UIViewController*)vc title:(NSString*)title message:(NSString*)message handler:(void (^)())handler;

// サービス一覧を取得
+ (void)fetchServicesWithHandler:(DConnectResponseBlocks)callback;

// サービス情報を取得
+ (void)fetchServiceInformationWithId:(NSString*)serviceId callback:(DConnectResponseBlocks)callback;

+ (NSString *)accessToken;


+ (void) setOnline:(BOOL)online;
+ (BOOL) isOnline;

@end
