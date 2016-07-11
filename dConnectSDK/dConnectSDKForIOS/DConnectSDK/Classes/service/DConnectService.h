//
//  DConnectService.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

//#import <Foundation/Foundation.h>
#import "DConnectServiceProvider.h"
#import "DConnectProfileProvider.h"

@interface DConnectService : NSObject<DConnectProfileProvider>

/*!
 @brief サービスID.
 */
@property (nonatomic, weak) NSString *mId;

/*!
 @brief サポートするプロファイル一覧(key:プロファイル名(小文字) value:DConnectProfile *).
 */
@property (nonatomic, weak) NSMutableDictionary *mProfiles;

@property (nonatomic, weak) NSString *mName;

@property (nonatomic, weak) NSString *mType;

@property BOOL mIsOnline;

@property (nonatomic, weak) NSString *mConfig;

- (instancetype) initWithServiceId: (NSString *)serviceId;

- (NSString *) serviceId;

- (void) setName: (NSString *)name;

- (NSString *) name;

- (void) setNetworkType: (NSString *) type;

- (NSString *) networkType;

- (void) setOnline: (BOOL) isOnline;

- (BOOL) isOnline;

- (NSString *) config;

- (void) setConfig: (NSString *) config;

- (BOOL) onRequest: request response: response;

@end
