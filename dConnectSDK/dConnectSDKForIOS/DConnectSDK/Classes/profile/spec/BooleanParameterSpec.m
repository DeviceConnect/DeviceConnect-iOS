//
//  BooleanParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanParameterSpec.h"
#import "BooleanDataSpec.h"

@implementation BooleanParameterSpec

- (instancetype) init {
    self = [super initWithDataSpec: [[BooleanDataSpec alloc] init]];
    return self;
}

@end
