//
//  IntegerParameterSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectSpecConstants.h"
#import "IntegerParameterSpec.h"

@interface IntegerParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic, strong) NSNumber *maximum;     // long値
@property(nonatomic, strong) NSNumber *minimum;     // long値
@property(nonatomic) BOOL exclusiveMaximum;
@property(nonatomic) BOOL exclusiveMinimum;
@property(nonatomic, strong) NSArray *mEnumList;    // NSNumber(long値)の配列

- (IntegerParameterSpec *) build;

@end
