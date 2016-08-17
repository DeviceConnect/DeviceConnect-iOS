//
//  DPAWSIoTUtils.h
//  dConnectDeviceAWSIoT
//
//  Created by zuvola on 2016/08/12.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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

@end
