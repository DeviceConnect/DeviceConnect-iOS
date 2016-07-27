//
//  DConnectServiceManager.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectApiSpecList.h"
#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectServiceProvider.h>



@interface DConnectServiceManager : DConnectServiceProvider

// DConnectApiSpecの配列
@property NSMutableArray *mApiSpecList;

@property (nonatomic, weak) DConnectApiSpecList *mApiSpecs;


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

- (void) setApiSpecDictionary: (DConnectApiSpecList *) dictionary;

- (void) addService: (DConnectService *) service;

- (void) removeService: (NSString *) serviceId;

- (DConnectService *) service: (NSString *) serviceId;

- (NSArray *) services;

- (BOOL) hasService: (NSString *)serviceId;


@end