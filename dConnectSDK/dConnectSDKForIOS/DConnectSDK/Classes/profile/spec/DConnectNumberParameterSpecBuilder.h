//
//  DConnectNumberParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectNumberParameterSpec.h"

@interface DConnectNumberParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;

@property(nonatomic, strong) NSNumber * maximum;    // double型

@property(nonatomic, strong) NSNumber * minimum;    // double型

@property(nonatomic) BOOL exclusiveMaximum;

@property(nonatomic) BOOL exclusiveMinimum;

- (DConnectNumberParameterSpec *) build;
@end
