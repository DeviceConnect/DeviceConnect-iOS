//
//  DConnectIntegerParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectSpecConstants.h"
#import "DConnectIntegerParameterSpec.h"

@interface DConnectIntegerParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic, strong) NSNumber *maximum;     // long値
@property(nonatomic, strong) NSNumber *minimum;     // long値
@property(nonatomic) BOOL exclusiveMaximum;
@property(nonatomic) BOOL exclusiveMinimum;
@property(nonatomic, strong) NSArray *enumList;     // NSNumber(long値)の配列

- (DConnectIntegerParameterSpec *) build;

@end
