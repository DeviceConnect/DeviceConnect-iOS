//
//  StringRequestParamSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringRequestParamSpecBuilder.h"

@interface StringRequestParamSpecBuilder()

@property NSString *mName;

@property BOOL mIsMandatory;

@property StringRequestParamSpecFormat mFormat;

@property NSNumber *mMaxLength; // int値を格納。nilなら省略。

@property NSNumber *mMinLength; // int値を格納。nilなら省略。

@property NSArray *mEnumList;   // NSStringの配列

@end


@implementation StringRequestParamSpecBuilder


- (id) init {
    
    self = [super init];
    
    if (self) {
        self.mName = nil;
        self.mIsMandatory = NO;
        self.mFormat = TEXT;
        self.mMaxLength = nil;
        self.mMinLength = nil;
        self.mEnumList = nil;
    }
    
    return self;
}

#pragma mark - StringRequestParamSpecBuilder Setter Method

- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)isMandatory:(BOOL)isMandatory {
    self.mIsMandatory = isMandatory;
    return self;
}

- (id)format:(StringRequestParamSpecFormat)format {
    self.mFormat = format;
    return self;
}

- (id)maxLength:(NSNumber *) maxLength {
    self.mMaxLength = maxLength;
    return self;
}

- (id)minLength:(NSNumber *) minLength {
    self.mMinLength = minLength;
    return self;
}

- (id)enumList:(NSArray *)enumList {
    self.mEnumList = enumList;
    return self;
}

#pragma mark - StringRequestParamSpecBuilder Builder Method


- (StringRequestParamSpec *) build {
    StringRequestParamSpec *paramSpec = [[StringRequestParamSpec alloc] init];
    
    [paramSpec setName: self.mName];
    [paramSpec setIsMandatory:self.mIsMandatory];
    [paramSpec setFormat:self.mFormat];
    [paramSpec setMaxLength: self.mMaxLength];
    [paramSpec setMinLength: self.mMinLength];
    [paramSpec setEnumList: self.mEnumList];

    return paramSpec;
}

@end
