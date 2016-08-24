//
//  FileParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "FileParameterSpec.h"
#import "FileDataSpec.h"

@implementation FileParameterSpec

- (instancetype) init {
    self = [super initWithDataSpec: [[FileDataSpec alloc] init]];
    return self;
}

@end
