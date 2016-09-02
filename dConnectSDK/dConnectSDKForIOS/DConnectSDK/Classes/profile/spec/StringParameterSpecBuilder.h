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
@property(nonatomic) int maxLength;
@property(nonatomic) int minLength;
@property(nonatomic, strong) NSArray *enums;

- (StringParameterSpec *) build;

@end
