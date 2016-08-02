//
//  ArrayDataSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectDataSpec.h"

@interface ArrayDataSpec : DConnectDataSpec

@property(nonatomic, strong) DConnectDataSpec *itemSpec;
@property(nonatomic, strong) NSNumber *maxLength;       // Int値。nilなら指定なし。
@property(nonatomic, strong) NSNumber *minLength;       // Int値。nilなら指定なし。

- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemsSpec;

@end
