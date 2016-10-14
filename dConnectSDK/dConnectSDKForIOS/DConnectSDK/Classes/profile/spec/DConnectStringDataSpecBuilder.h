//
//  DConnectStringDataSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringDataSpecBuilder.h"
#import "DConnectStringDataSpec.h"

@interface DConnectStringDataSpecBuilder : NSObject

@property (nonatomic) DConnectSpecDataFormat format;

@property (nonatomic, strong) NSNumber *maxLength; // int値を格納。nilなら省略。

@property (nonatomic, strong) NSNumber *minLength; // int値を格納。nilなら省略。

@property (nonatomic, strong) NSArray *enums;       // NSStringの配列

- (DConnectStringDataSpec *)build;

@end
