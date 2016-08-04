//
//  DConnectDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDataSpec.h"
#import "DConnectSpecConstants.h"

@implementation DConnectDataSpec

- (instancetype) initWithDataType: (DConnectSpecDataType) dataType {

    self = [super init];
    if (self) {
        [self setDataType: dataType];
    }
    return self;
}

#pragma mark - Abstruct Methods.

- (BOOL) validate: (id) param {
    return NO;
}

@end
