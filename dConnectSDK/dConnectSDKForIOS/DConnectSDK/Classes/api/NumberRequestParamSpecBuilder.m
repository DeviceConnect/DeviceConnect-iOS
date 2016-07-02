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

@property BOOL mIsMandatory;

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
        self.mIsMandatory = NO;
        self.mFormat = FLOAT;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
    }
    
    return self;
}

#pragma mark - NumberRequestParamSpecBuilder Setter Method


- (id)name: (NSString *) name {
    self.mName = name;
    return self;
}

- (id)isMandatory:(BOOL)isMandatory {
    self.mIsMandatory = isMandatory;
    return self;
}

- (id)format:(NumberRequestParamSpecFormat)format {
    self.mFormat = format;
    return self;
}

- (id)maxValue:(double)maxValue {
    self.mMaxValue = [[NSNumber alloc] initWithDouble: maxValue];
    return self;
}

- (id)minValue:(double)minValue {
    self.mMinValue = [[NSNumber alloc] initWithDouble: minValue];
    return self;
}

- (id)exclusiveMaxValue:(double)exclusiveMaxValue {
    self.mExclusiveMaxValue = [[NSNumber alloc] initWithDouble: exclusiveMaxValue];
    return self;
}

- (id)exclusiveMinValue:(double)exclusiveMinValue {
    self.mExclusiveMinValue = [[NSNumber alloc] initWithDouble: exclusiveMinValue];
    return self;
}

#pragma mark - NumberRequestParamSpecBuilder Builder Method


- (NumberRequestParamSpec *) build {
    NumberRequestParamSpec *paramSpec = [[NumberRequestParamSpec alloc] init];
    
    [paramSpec setName: self.mName];
    [paramSpec setIsMandatory: self.mIsMandatory];
    [paramSpec setFormat: self.mFormat];
    [paramSpec setMaxValue: self.mMaxValue];
    [paramSpec setMinValue: self.mMinValue];
    [paramSpec setExclusiveMaxValue: self.mExclusiveMaxValue];
    [paramSpec setExclusiveMinValue: self.mExclusiveMinValue];

    return paramSpec;
}

@end
