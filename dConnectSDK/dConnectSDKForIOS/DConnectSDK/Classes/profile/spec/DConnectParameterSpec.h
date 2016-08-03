//
//  DConnectParameterSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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
