//
//  NumberRequestParamSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberRequestParamSpecBuilder.h"

@interface NumberRequestParamSpecBuilder()

@property NSString * mName;

@property NumberRequestParamSpecFormat mFormat;

@property NSNumber * mMaxValue;

@property NSNumber * mMinValue;

@property NSNumber * mExclusiveMaxValue;

@property NSNumber * mExclusiveMinValue;

@end


@implementation NumberRequestParamSpecBuilder


- (id) init {
    
    self = [super init];
    
    if (self) {
        self.mName = nil;
        self.mFormat = FLOAT;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
    }
    
    return self;
}

#pragma mark - NumberRequestParamSpecBuilder Setter Method

/*
- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)isMandatory:(BOOL)isMandatory {
    self.mIsMandatory = isMandatory;
    return self;
}
*/
- (id)name: (NSString *) name {
    self.mName = name;
    return self;
}

- (id)format:(NumberRequestParamSpecFormat)format {
    self.mFormat = format;
    return self;
}

- (id)maxValue:(NSNumber *)maxValue {
    self.mMaxValue = maxValue;
    return self;
}

- (id)minValue:(NSNumber *)minValue {
    self.mMinValue = minValue;
    return self;
}

- (id)exclusiveMaxValue:(NSNumber *)exclusiveMaxValue {
    self.mExclusiveMaxValue = exclusiveMaxValue;
    return self;
}

- (id)exclusiveMinValue:(NSNumber *)exclusiveMinValue {
    self.mExclusiveMinValue = exclusiveMinValue;
    return self;
}

#pragma mark - NumberRequestParamSpecBuilder Builder Method


- (NumberRequestParamSpec *) build {
    NumberRequestParamSpec *paramSpec = [[NumberRequestParamSpec alloc] init];
    
    [paramSpec setName: self.mName];
    [paramSpec setFormat: self.mFormat];
    [paramSpec setMaxValue: self.mMaxValue];
    [paramSpec setMinValue: self.mMinValue];
    [paramSpec setExclusiveMaxValue: self.mExclusiveMaxValue];
    [paramSpec setExclusiveMinValue: self.mExclusiveMinValue];

    return paramSpec;
}

@end
