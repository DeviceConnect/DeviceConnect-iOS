//
//  DConnectApiEntity.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import <DConnectSDK/DConnectResponseMessage.h>
#import <DConnectSDK/DConnectApiSpec.h>

typedef BOOL (^DConnectApiFunction)(DConnectRequestMessage*, DConnectResponseMessage*);

/*!
 @class DConnectApiEntity
 @brief Device Connect APIを実装するオブジェクト。
 */
@interface DConnectApiEntity : NSObject<NSCopying>

/*!
 @brief APIのメソッド名。
 */
@property (nonatomic, strong) NSString *method;

/*!
 @brief APIのパス名。
 */
@property (nonatomic, strong) NSString *path;

/*!
 @brief APIを実装するブロック。
 */
@property (nonatomic, strong) DConnectApiFunction api;

/*!
 @brief APIの仕様を定義するオブジェクトのインスタンス。
 */
@property (nonatomic, strong) DConnectApiSpec *apiSpec;

@end
