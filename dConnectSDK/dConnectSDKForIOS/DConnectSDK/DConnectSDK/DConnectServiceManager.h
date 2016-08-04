//
//  DConnectServiceManager.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectServiceProvider.h>
#import <DConnectSDK/DConnectPluginSpec.h>

@interface DConnectServiceManager : DConnectServiceProvider

@property(nonatomic, strong) DConnectPluginSpec *pluginSpec;


/*!
 DConnectServiceManagerインスタンス取得.
 @param[in]  clazz   クラスインスタンス
 @return ServiceManagerインスタンス。クラスインスタンスが一緒であれば同じ値を返す。
 */
+ (DConnectServiceManager *)sharedForClass: (Class)clazz;

/*!
 DConnectServiceManagerインスタンス取得.(DConnectServiceManager内部で利用する)
 @param[in]  key   キー
 @return ServiceManagerインスタンス。キーが一緒であれば同じ値を返す。
 */
+ (DConnectServiceManager *)sharedForKey: (NSString *)key;

- (void) addService: (DConnectService *) service;

- (void) removeService: (NSString *) serviceId;

- (DConnectService *) service: (NSString *) serviceId;

- (NSArray *) services;

- (BOOL) hasService: (NSString *)serviceId;


@end
