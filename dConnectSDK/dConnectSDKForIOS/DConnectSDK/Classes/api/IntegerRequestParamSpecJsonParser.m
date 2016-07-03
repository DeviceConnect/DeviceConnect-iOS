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
    NSNumber *numMandatory = [json objectForKey: DConnectRequestParamSpecJsonKeyMandatory];
    NSString *strFormat = [json objectForKey: IntegerRequestParamSpecJsonKeyFormat];
    NSString *strMaxValue = [json objectForKey: IntegerRequestParamSpecJsonKeyMaxValue];
    NSString *strMinValue = [json objectForKey: IntegerRequestParamSpecJsonKeyMinValue];
    NSString *strExclusiveMaxValue = [json objectForKey: IntegerRequestParamSpecJsonKeyExclusiveMaxValue];
    NSString *strExclusiveMinValue = [json objectForKey: IntegerRequestParamSpecJsonKeyExclusiveMinValue];
    NSArray *enumArray = [json objectForKey: IntegerRequestParamSpecJsonKeyEnum];
    
    
    IntegerRequestParamSpecBuilder *builder = [[IntegerRequestParamSpecBuilder alloc] init];
    
    // name
    if (!name) {
        @throw @"name not found";
    }
    if (![name isKindOfClass: [NSString class]]) {
        @throw [NSString stringWithFormat: @"name not string : %@", [[name class] description]];
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
    IntegerRequestParamSpecFormat format = INT32;
    if (strFormat) {
        // 不正値なら例外スロー(JSONException相当)
        format = [IntegerRequestParamSpec parseFormat: strFormat];
    }
    [builder format: format];

    // maxValue
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
    
    // minValue
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
    
    // exclusiveMaxValue
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
    
    // exclusiveMinValue
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
    
    // enum
    if (enumArray) {
        /***/
        NSLog(@"enum count: %d", (int)[enumArray count]);
        
        
        /***/
        
        
        if (![enumArray isKindOfClass: [NSArray class]]) {
            @throw @"enum not array";
        }
        
        // JSON文字列をNSDataに変換
        [builder enumList: enumArray];
    }
    
    // buildしてJSONを返す
    return [builder build];
}

@end
