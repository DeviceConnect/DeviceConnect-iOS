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

// メニュー作成
+ (UIAlertController*)createMenu:(NSArray*)items handler:(void (^)(int index))handler;

@end
