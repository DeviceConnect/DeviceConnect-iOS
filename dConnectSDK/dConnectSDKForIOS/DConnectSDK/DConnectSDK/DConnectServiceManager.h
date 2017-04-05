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

/*!
 @class DConnectServiceManager
 @brief 当該プラグインのDeviceConnectサービスを管理する。
 */
@interface DConnectServiceManager : DConnectServiceProvider<OnStatusChangeListener>


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

/*!
 @brief プラグインを対応づける。
 @param[in] plugin DConnectDevicePluginのインスタンス。
 */
- (void) setPlugin: (id) plugin;

@end
