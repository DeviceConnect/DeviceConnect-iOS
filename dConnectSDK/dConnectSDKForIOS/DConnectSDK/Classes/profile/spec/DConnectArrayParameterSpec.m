//
//  DConnectArrayParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectArrayParameterSpec.h"

@implementation DConnectArrayParameterSpec

- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemsSpec {
    
    self = [super initWithDataSpec: [[DConnectArrayDataSpec alloc] initWithItemsSpec:itemsSpec]];
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

- (DConnectArrayDataSpec *) arrayDataSpec {
    return (DConnectArrayDataSpec *)[self dataSpec];
}

@end
