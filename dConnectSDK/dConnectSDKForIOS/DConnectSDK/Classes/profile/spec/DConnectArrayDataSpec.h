//
//  DConnectArrayDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDataSpec.h"

@interface DConnectArrayDataSpec : DConnectDataSpec

@property(nonatomic, strong) DConnectDataSpec *itemsSpec;
@property(nonatomic, strong) NSNumber *maxLength;       // Int値。nilなら指定なし。
@property(nonatomic, strong) NSNumber *minLength;       // Int値。nilなら指定なし。

- (instancetype) initWithItemsSpec: (DConnectDataSpec *) itemsSpec;

@end
