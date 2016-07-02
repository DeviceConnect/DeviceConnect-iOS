//
//  IntegerRequestParamSpecJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "IntegerRequestParamSpecJsonParser.h"
#import "IntegerRequestParamSpecBuilder.h"

@implementation IntegerRequestParamSpecJsonParser

+ (IntegerRequestParamSpec *)fromJson: (NSDictionary *) json {
    
    NSString *name = [json objectForKey: DConnectRequestParamSpecJsonKeyName];
    NSString *strMandatory = [json objectForKey: DConnectRequestParamSpecJsonKeyMandatory];
    NSString *strFormat = [json objectForKey: IntegerRequestParamSpecJsonKeyFormat];
    NSString *strMaxValue = [json objectForKey: IntegerRequestParamSpecJsonKeyMaxValue];
    NSString *strMinValue = [json objectForKey: IntegerRequestParamSpecJsonKeyMinValue];
    NSString *strExclusiveMaxValue = [json objectForKey: IntegerRequestParamSpecJsonKeyExclusiveMaxValue];
    NSString *strExclusiveMinValue = [json objectForKey: IntegerRequestParamSpecJsonKeyExclusiveMinValue];
    NSString *strEnumJson = [json objectForKey: IntegerRequestParamSpecJsonKeyEnum];
    
    // 不正値なら例外スロー(JSONException相当)
    BOOL isMandatory = [DConnectRequestParamSpec parseBool:strMandatory];
    
    IntegerRequestParamSpecFormat format = INT32;
    if (strFormat) {
        // 不正値なら例外スロー(JSONException相当)
        format = [IntegerRequestParamSpec parseFormat: strFormat];
    }
    
    IntegerRequestParamSpecBuilder *builder = [[IntegerRequestParamSpecBuilder alloc] init];
    [builder name: name];
    [builder isMandatory: isMandatory];
    
    if (strMaxValue) {
        if ([DConnectRequestParamSpec isDigit: strMaxValue]) {
            if ((format == INT32 && INT_MIN <= [strMaxValue longLongValue] && [strMaxValue longLongValue] <= INT_MAX) ||
                (format == INT64 && LONG_MIN <= [strMaxValue longLongValue] && [strMaxValue longLongValue] <= LONG_MAX)) {
                [builder maxValue: (long)[strMaxValue longLongValue]];
            } else {
                // 不正値なら例外スロー(JSONException相当)
                @throw [NSString stringWithFormat: @"maxValue is invalid : %@", strMaxValue];
            }
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"maxValue is invalid : %@", strMaxValue];
        }
    }
    if (strMinValue) {
        if ([DConnectRequestParamSpec isDigit: strMinValue]) {
            if ((format == INT32 && INT_MIN <= [strMinValue longLongValue] && [strMinValue longLongValue] <= INT_MAX) ||
                (format == INT64 && LONG_MIN <= [strMinValue longLongValue] && [strMinValue longLongValue] <= LONG_MAX)) {
                [builder minValue: (long)[strMinValue longLongValue]];
            } else {
                // 不正値なら例外スロー(JSONException相当)
                @throw [NSString stringWithFormat: @"minValue is invalid : %@", strMinValue];
            }
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"minValue is invalid : %@", strMinValue];
        }
    }
    
    if (strExclusiveMaxValue) {
        if ([DConnectRequestParamSpec isDigit: strExclusiveMaxValue]) {
            if ((format == INT32 && INT_MIN <= [strExclusiveMaxValue longLongValue] && [strExclusiveMaxValue longLongValue] <= INT_MAX) ||
                (format == INT64 && LONG_MIN <= [strExclusiveMaxValue longLongValue] && [strExclusiveMaxValue longLongValue] <= LONG_MAX)) {
                [builder exclusiveMaxValue: (long)[strExclusiveMaxValue longLongValue]];
            } else {
                // 不正値なら例外スロー(JSONException相当)
                @throw [NSString stringWithFormat: @"exclusiveMaxValue is invalid : %@", strExclusiveMaxValue];
            }
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"exclusiveMaxValue is invalid : %@", strExclusiveMaxValue];
        }
    }
    if (strExclusiveMinValue) {
        if ([DConnectRequestParamSpec isDigit: strExclusiveMinValue]) {
            if ((format == INT32 && INT_MIN <= [strExclusiveMinValue longLongValue] && [strExclusiveMinValue longLongValue] <= INT_MAX) ||
                (format == INT64 && LONG_MIN <= [strExclusiveMinValue longLongValue] && [strExclusiveMinValue longLongValue] <= LONG_MAX)) {
                [builder exclusiveMinValue: (long)[strExclusiveMinValue longLongValue]];
            } else {
                // 不正値なら例外スロー(JSONException相当)
                @throw [NSString stringWithFormat: @"exclusiveMinValue is invalid : %@", strExclusiveMinValue];
            }
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"exclusiveMinValue is invalid : %@", strExclusiveMinValue];
        }
    }
    
    if (strEnumJson) {
        
        // JSON文字列をNSDataに変換
        NSData *enumJsonData = [strEnumJson dataUsingEncoding:NSUnicodeStringEncoding];
        
        // JSON を NSArray に変換する
        NSError *error;
        id enumArray = [NSJSONSerialization JSONObjectWithData:enumJsonData
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
        if (error != nil) {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"JSON parse error: %@", error];
        }
        
        if ([enumArray isMemberOfClass: [NSArray class]]) {
            [builder enumList: (NSArray *)enumArray];
        }
    }
    
    return [builder build];
}

@end
