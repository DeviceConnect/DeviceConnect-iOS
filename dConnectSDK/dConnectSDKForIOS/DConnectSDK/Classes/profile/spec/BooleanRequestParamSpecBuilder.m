//
//  BooleanRequestParamSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanRequestParamSpecBuilder.h"

@interface BooleanRequestParamSpecBuilder()

@property NSString *mName;

@property BOOL mIsMandatory;

@end


@implementation BooleanRequestParamSpecBuilder


- (id) init {
    
    self = [super init];
    
    if (self) {
        self.mName = nil;
        self.mIsMandatory = NO;
    }
    
    return self;
}

#pragma mark - BooleanRequestParamSpecBuilder Setter Method

- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)isMandatory:(BOOL)isMandatory {
    self.mIsMandatory = isMandatory;
    return self;
}


#pragma mark - BooleanRequestParamSpecBuilder Builder Method


- (BooleanRequestParamSpec *) build {
    BooleanRequestParamSpec *paramSpec = [[BooleanRequestParamSpec alloc] init];
    [paramSpec setName: self.mName];
    [paramSpec setIsMandatory: self.mIsMandatory];
    return paramSpec;
}

@end
