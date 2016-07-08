//
//  DConnectService.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DConnectService : NSObject

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


@end
