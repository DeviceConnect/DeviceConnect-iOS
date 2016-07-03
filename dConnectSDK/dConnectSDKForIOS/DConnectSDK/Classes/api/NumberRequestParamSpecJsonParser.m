//
//  NumberRequestParamSpecJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberRequestParamSpecJsonParser.h"
#import "NumberRequestParamSpecBuilder.h"

@implementation NumberRequestParamSpecJsonParser

+ (NumberRequestParamSpec *)fromJson: (NSDictionary *) json {
    
    NSString *name = [json objectForKey: DConnectRequestParamSpecJsonKeyName];
    NSNumber *numMandatory = [json objectForKey: DConnectRequestParamSpecJsonKeyMandatory];
    NSString *strFormat = [json objectForKey: NumberRequestParamSpecJsonKeyFormat];
    NSNumber *numMaxValue = [json objectForKey: NumberRequestParamSpecJsonKeyMaxValue];
    NSNumber *numMinValue = [json objectForKey: NumberRequestParamSpecJsonKeyMinValue];
    NSNumber *numExclusiveMaxValue = [json objectForKey: NumberRequestParamSpecJsonKeyExclusiveMaxValue];
    NSNumber *numExclusiveMinValue = [json objectForKey: NumberRequestParamSpecJsonKeyExclusiveMinValue];
    
    
    NumberRequestParamSpecBuilder *builder = [[NumberRequestParamSpecBuilder alloc] init];
    
    // name
    if (!name) {
        @throw @"name not found";
    }
    if (![name isKindOfClass: [NSString class]]) {
        @throw @"name not string";
    }
    [builder name: name];
    
    // isMandatory
    if (numMandatory) {
        if (![numMandatory isKindOfClass: [NSNumber class]]) {
            @throw @"mandatory not bool";
        }
    }
    [builder isMandatory: [numMandatory boolValue]];
    
    // format
    NumberRequestParamSpecFormat format = FLOAT;
    if (strFormat) {
        // 不正値なら例外スロー(JSONException相当)
        format = [NumberRequestParamSpec parseFormat: strFormat];
    }
    [builder format: format];
    
    // maxValue
    if (numMaxValue) {
        if (![numMaxValue isKindOfClass: [NSNumber class]]) {
            @throw @"maxValue not number";
        }
        [builder maxValue: [numMaxValue doubleValue]];
    }

    // minValue
    if (numMinValue) {
        if (![numMinValue isKindOfClass: [NSNumber class]]) {
            @throw @"minValue not number";
        }
        [builder minValue: [numMinValue doubleValue]];
    }
    
    // exclusiveMaxValue
    if (numExclusiveMaxValue) {
        if (![numMaxValue isKindOfClass: [NSNumber class]]) {
            @throw @"exclusiveMaxValue not number";
        }
        [builder exclusiveMaxValue: [numExclusiveMaxValue doubleValue]];
    }
    
    // exclusiveMinValue
    if (numExclusiveMinValue) {
        if (![numExclusiveMinValue isKindOfClass: [NSNumber class]]) {
            @throw @"exclusiveMinValue not number";
        }
        [builder exclusiveMinValue: [numExclusiveMinValue doubleValue]];
    }
    
    return [builder build];
}


@end
