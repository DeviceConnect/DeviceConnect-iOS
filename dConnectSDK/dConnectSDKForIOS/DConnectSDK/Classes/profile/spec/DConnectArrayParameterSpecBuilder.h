//
//  DConnectArrayParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectDataSpec.h"
#import "DConnectArrayParameterSpec.h"

@interface DConnectArrayParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic, strong) DConnectDataSpec *itemSpec;
@property(nonatomic, strong) NSNumber *maxLength;       // int型,nilなら省略
@property(nonatomic, strong) NSNumber *minLength;       // int型,nilなら省略

- (DConnectArrayParameterSpec *) build;

@end
