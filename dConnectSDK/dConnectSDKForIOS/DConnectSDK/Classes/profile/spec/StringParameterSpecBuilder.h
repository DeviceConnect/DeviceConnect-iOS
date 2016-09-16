//
//  StringParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectSpecConstants.h"
#import "StringParameterSpec.h"

@interface StringParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic) NSNumber *maxLength;
@property(nonatomic) NSNumber *minLength;
@property(nonatomic, strong) NSArray *enums;

- (StringParameterSpec *) build;

@end
