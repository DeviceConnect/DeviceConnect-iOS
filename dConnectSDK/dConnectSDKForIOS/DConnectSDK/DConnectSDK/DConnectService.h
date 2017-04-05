//
//  DConnectService.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectServiceProvider.h>
#import <DConnectSDK/DConnectProfileProvider.h>
#import <DConnectSDK/DConnectServiceInformationProfile.h>

extern NSString * const DConnectServiceAnonymousOrigin;

extern NSString * const DConnectServiceInnerType;
extern NSString * const DConnectServiceInnerTypeHttp;

@class DConnectService;

/*!
 @brief DConnectServiceの状態変更通知を受信するリスナー。
 */
@protocol OnStatusChangeListener <NSObject>

/*!
 @brief DConnectServiceの状態が変更された時に呼び出される。
 @param[in] 状態の変更されたDConnectServiceのインスタンス。
 */
- (void) didStatusChange: (DConnectService *)service;

@end

/*!
 @class DConnectService
 @brief Device Connect APIサービス。
 */
@interface DConnectService : DConnectProfileProvider<DConnectServiceInformationProfileDataSource>

/*!
 @brief サービスID。
 */
@property(nonatomic, strong) NSString *serviceId;

/*!
 @brief サービス名。
 */
@property(nonatomic, strong) NSString *name;

/*!
 @brief ネットワーク種別。
 */
@property(nonatomic, strong) NSString *networkType;

/*!
 @brief オンライン状態。
 
 ホストデバイスと接続されているかどうかを示すフラグ。
 */
@property(readwrite, getter=online, setter=setOnline:) BOOL online;

/*!
 @brief コンフィグ。
 
 サービスごとに任意に設定可能な文字列。
 */
@property(nonatomic, strong) NSString *config;

/*!
 @brief 当該サービスの状態変更を通知するリスナー。
 */
@property(nonatomic, weak) id<OnStatusChangeListener> statusListener;

/*!
 @brief DConnectServiceのインスタンスを生成する。
 @param[in] serviceId サービスID。
 @param[in] plugin DConnectDevicePluginのインスタンス。
 @return DConnectServiceのインスタンス。
 */
- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id) plugin;

/*!
 @brief リクエスト受信時に実行される。
 @return 同期的にリクエストを処理する場合はYES、それ以外の場合(非同期処理を行う場合)はNO。後者の場合は、非同期処理完了後に明示的にレスポンス送信処理を実行すること。
 */
- (BOOL) didReceiveRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *)response;

@end
