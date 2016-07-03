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
    NSString *strMaxValue = [json objectForKey: NumberRequestParamSpecJsonKeyMaxValue];
    NSString *strMinValue = [json objectForKey: NumberRequestParamSpecJsonKeyMinValue];
    NSString *strExclusiveMaxValue = [json objectForKey: NumberRequestParamSpecJsonKeyExclusiveMaxValue];
    NSString *strExclusiveMinValue = [json objectForKey: NumberRequestParamSpecJsonKeyExclusiveMinValue];
    
    
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
    if (strMaxValue) {
        if ([DConnectRequestParamSpec isNumber: strMaxValue]) {
            [builder maxValue: [strMaxValue doubleValue]];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"maxValue is invalid : %@", strMaxValue];
        }
    }

    // minValue
    if (strMinValue) {
        if ([DConnectRequestParamSpec isNumber: strMinValue]) {
            [builder minValue: [strMinValue doubleValue]];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"minValue is invalid : %@", strMinValue];
        }
    }
    
    if (strExclusiveMaxValue) {
        if ([DConnectRequestParamSpec isNumber: strExclusiveMaxValue]) {
            [builder exclusiveMaxValue: [strExclusiveMaxValue doubleValue]];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"exclusiveMaxValue is invalid : %@", strExclusiveMaxValue];
        }
    }
    if (strExclusiveMinValue) {
        if ([DConnectRequestParamSpec isNumber: strExclusiveMinValue]) {
            [builder exclusiveMinValue: [strExclusiveMinValue doubleValue]];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"exclusiveMinValue is invalid : %@", strExclusiveMinValue];
        }
    }
    
    return [builder build];
}


@end
