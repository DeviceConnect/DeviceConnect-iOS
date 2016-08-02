//
//  StringDataSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringDataSpecBuilder.h"
#import "StringDataSpec.h"

@interface StringDataSpecBuilder : NSObject

@property (nonatomic) DConnectSpecDataFormat format;

@property (nonatomic, strong) NSNumber *maxLength; // int値を格納。nilなら省略。

@property (nonatomic, strong) NSNumber *minLength; // int値を格納。nilなら省略。

@property (nonatomic, strong) NSArray *enumList;   // NSStringの配列

- (StringDataSpec *)build;

@end
