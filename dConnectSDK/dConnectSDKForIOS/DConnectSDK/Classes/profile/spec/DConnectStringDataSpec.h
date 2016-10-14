//
//  DConnectStringDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"
#import "DConnectSpecConstants.h"

@interface DConnectStringDataSpec : DConnectDataSpec

@property (nonatomic) DConnectSpecDataFormat dataFormat;
@property (nonatomic, strong) NSNumber *maxLength; // int値を格納。nilなら省略。
@property (nonatomic, strong) NSNumber *minLength; // int値を格納。nilなら省略。
@property (nonatomic, strong) NSArray *enums;       // NSStringの配列

- (instancetype)initWitDataFormat: (DConnectSpecDataFormat) dataFormat;

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj;

@end
