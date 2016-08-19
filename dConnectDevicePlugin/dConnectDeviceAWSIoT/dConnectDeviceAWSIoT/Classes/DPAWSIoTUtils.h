//
//  DPAWSIoTUtils.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface DPAWSIoTUtils : NSObject

// ManagerUUIDを返す
+ (NSString*)managerUUID;
// ManagerNameを返す
+ (NSString*)managerName;

// アカウントの設定があるか
+ (BOOL)hasAccount;
// アカウントの設定をクリア
+ (void)clearAccount;
// アカウントを設定
+ (void)setAccount:(NSString*)accessKey secretKey:(NSString*)secretKey region:(NSInteger)region;

// ログイン
+ (void)loginWithHandler:(void (^)(NSError *error))handler;

// ローディング画面表示
+ (void)showLoadingHUD:(UIStoryboard*)storyboard;
// ローディング画面非表示
+ (void)hideLoadingHUD;

// Shadowからデバイス情報を取得する
+ (void)fetchManagerInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler;
// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler;

// メニュー作成
+ (UIAlertController*)createMenu:(NSArray*)items handler:(void (^)(int index))handler;

@end
