//
//  DConnectBooleanParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBooleanParameterSpec.h"
#import "DConnectBooleanDataSpec.h"

@implementation DConnectBooleanParameterSpec

- (instancetype) init {
    self = [super initWithDataSpec: [[DConnectBooleanDataSpec alloc] init]];
    return self;
}

@end
