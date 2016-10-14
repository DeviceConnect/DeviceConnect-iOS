//
//  DConnectStringParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectSpecConstants.h"
#import "DConnectStringParameterSpec.h"

@interface DConnectStringParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic) NSNumber *maxLength;
@property(nonatomic) NSNumber *minLength;
@property(nonatomic, strong) NSArray *enums;

- (DConnectStringParameterSpec *) build;

@end
