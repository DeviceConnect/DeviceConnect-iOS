//
//  DConnectFileDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectFileDataSpec.h"

@implementation DConnectFileDataSpec

- (instancetype) init {
    self = [super initWithDataType:FILE_];
    return self;
}

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) param {
    return true;
}

@end
