//
//  DConnectFileParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectFileParameterSpec.h"
#import "DConnectFileDataSpec.h"

@implementation DConnectFileParameterSpec

- (instancetype) init {
    self = [super initWithDataSpec: [[DConnectFileDataSpec alloc] init]];
    return self;
}

@end
