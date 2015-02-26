//
//  LocalOAuthPackageInfo.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface LocalOAuthPackageInfo : NSObject

/** パッケージ名. */
@property NSString *packageName;
    
/** サービスID(アプリの場合はnilを設定する). */
@property NSString *serviceId;

/*!
    コンストラクタ(アプリを指定する場合).
    @param[in] packageName	パッケージ名.
 */
- (LocalOAuthPackageInfo *) initWithPackageName: (NSString *)packageName;

/*!
    コンストラクタ(デバイスプラグインを指定する場合).
    @param[in] packageName	パッケージ名.
    @param[in] serviceId		サービスID.
 */
- (LocalOAuthPackageInfo *) initWithPackageNameServiceId: (NSString *)packageName serviceId:(NSString *)serviceId;

/*!
    オブジェクト比較.
    @param o	比較対象のオブジェクト
    @return YES: 同じ値を持つオブジェクトである。 / NO: 異なる値を持っている。
 */
- (BOOL) equals: (LocalOAuthPackageInfo *) info;



@end
