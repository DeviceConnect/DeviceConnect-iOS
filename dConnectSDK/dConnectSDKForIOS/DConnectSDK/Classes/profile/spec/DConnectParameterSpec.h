//
//  DConnectParameterSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDataSpec.h"

@interface DConnectParameterSpec : DConnectDataSpec

@property (nonatomic, strong) DConnectDataSpec *dataSpec;

@property (nonatomic, strong) NSString *name;

@property (nonatomic) BOOL isRequired;

/*!
 @brief コンストラクタ.
 
 @param[in] dataSpec リクエストパラメータとして受け付けるデータの仕様
 */
- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemSpec;

/*!
 @brief データの種類を取得する.
 
 @return データの種類
 */
- (DConnectSpecDataType) dataType;

@end
