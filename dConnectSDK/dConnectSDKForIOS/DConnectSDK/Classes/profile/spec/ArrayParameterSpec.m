//
//  ArrayParameterSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "ArrayParameterSpec.h"

@implementation ArrayParameterSpec

- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemSpec {
    
    self = [super initWithDataSpec: [[ArrayDataSpec alloc] initWithDataSpec:itemSpec]];
    return  self;
}

- (DConnectDataSpec *) itemSpec {
    return [[self arrayDataSpec] itemsSpec];
}

- (NSNumber *) maxLength {
    return [[self arrayDataSpec] maxLength];
}

- (void) setMaxLength: (NSNumber *) maxLength {
    [[self arrayDataSpec] setMaxLength: maxLength];
}

- (NSNumber *) minLength {
    return [[self arrayDataSpec] minLength];
}

- (void) setMinLength: (NSNumber *) minLength {
    [[self arrayDataSpec] setMinLength: minLength];
}

#pragma mark - Private Methods.

- (ArrayDataSpec *) arrayDataSpec {
    return (ArrayDataSpec *)[self dataSpec];
}

@end
