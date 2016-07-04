//
//  IntegerRequestParamSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "IntegerRequestParamSpecBuilder.h"

@interface IntegerRequestParamSpecBuilder()

@property NSString * mName;

@property BOOL mIsMandatory;

@property IntegerRequestParamSpecFormat mFormat;

@property NSNumber * mMaxValue;

@property NSNumber * mMinValue;

@property NSNumber * mExclusiveMaxValue;

@property NSNumber * mExclusiveMinValue;

@property NSArray * mEnumList;

@end


@implementation IntegerRequestParamSpecBuilder


- (id) init {
    
    self = [super init];
    
    if (self) {
        // 初期値設定
        self.mName = nil;
        self.mIsMandatory = NO;
        self.mFormat = INT32;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
        self.mEnumList = nil;
    }
    
    return self;
}

#pragma mark - IntegerRequestParamSpecBuilder Setter Method

- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)isMandatory: (BOOL)isMandatory {
    self.mIsMandatory = isMandatory;
    return self;
}


- (id)format:(IntegerRequestParamSpecFormat)format {
    self.mFormat = format;
    return self;
}

- (id)maxValue:(long)maxValue {
    self.mMaxValue = [[NSNumber alloc] initWithLong: maxValue];
    return self;
}

- (id)minValue:(long)minValue {
    self.mMinValue = [[NSNumber alloc] initWithLong: minValue];
    return self;
}

- (id)exclusiveMaxValue:(long)exclusiveMaxValue {
    self.mExclusiveMaxValue = [[NSNumber alloc] initWithLong: exclusiveMaxValue];
    return self;
}

- (id)exclusiveMinValue:(long)exclusiveMinValue {
    self.mExclusiveMinValue = [[NSNumber alloc] initWithLong: exclusiveMinValue];
    return self;
}

- (id)enumList:(NSArray *)enumList {
    self.mEnumList = enumList;
    return self;
}


#pragma mark - IntegerRequestParamSpecBuilder Builder Method


- (IntegerRequestParamSpec *) build {
    IntegerRequestParamSpec *paramSpec = [[IntegerRequestParamSpec alloc] initWithFormat: self.mFormat];
    [paramSpec setName: self.mName];
    [paramSpec setMaxValue: self.mMaxValue];
    [paramSpec setMinValue: self.mMinValue];
    [paramSpec setExclusiveMaxValue: self.mExclusiveMaxValue];
    [paramSpec setExclusiveMinValue: self.mExclusiveMinValue];
    [paramSpec setEnumList: self.mEnumList];
    return paramSpec;
}

@end
