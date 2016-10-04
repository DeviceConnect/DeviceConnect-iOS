//
//  DConnectIntegerDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"

@interface DConnectIntegerDataSpec : DConnectDataSpec

@property (nonatomic) DConnectSpecDataFormat format;
@property (nonatomic, strong) NSNumber *maximum;        // long値を格納
@property (nonatomic, strong) NSNumber *minimum;        // long値を格納
@property (nonatomic) BOOL exclusiveMaximum;
@property (nonatomic) BOOL exclusiveMinimum;
@property (nonatomic, strong) NSArray *enumList;        // NSNumber(long)値の配列

- (instancetype)initWithFormat: (DConnectSpecDataFormat) format;

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj;

@end
