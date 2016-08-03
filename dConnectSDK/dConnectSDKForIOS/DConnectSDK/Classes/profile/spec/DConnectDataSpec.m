//
//  DConnectDataSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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
