//
//  DConnectNumberDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"

@interface DConnectNumberDataSpec : DConnectDataSpec

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic, strong) NSNumber *maximum; // double値を格納。nilなら省略。
@property(nonatomic, strong) NSNumber *minimum; // double値を格納。nilなら省略。
@property(nonatomic) BOOL exclusiveMaximum;
@property(nonatomic) BOOL exclusiveMinimum;

- (instancetype)initWithDataFormat:(DConnectSpecDataFormat) format;

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj;

@end
