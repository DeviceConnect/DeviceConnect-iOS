//
//  StringRequestParamSpecJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringRequestParamSpecJsonParser.h"
#import "StringRequestParamSpecBuilder.h"

@implementation StringRequestParamSpecJsonParser

+ (StringRequestParamSpec *)fromJson: (NSDictionary *) json {
    
    NSString *name = [json objectForKey: DConnectRequestParamSpecJsonKeyName];
    NSNumber *numMandatory = [json objectForKey: DConnectRequestParamSpecJsonKeyMandatory];
    NSString *strFormat = [json objectForKey: StringRequestParamSpecJsonKeyFormat];
    NSString *strMaxLength = [json objectForKey: StringRequestParamSpecJsonKeyMaxLength];
    NSString *strMinLength = [json objectForKey: StringRequestParamSpecJsonKeyMinLength];
    NSArray *enumArray = [json objectForKey: StringRequestParamSpecJsonKeyEnum];
    
    
    StringRequestParamSpecBuilder *builder = [[StringRequestParamSpecBuilder alloc] init];
    
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
    StringRequestParamSpecFormat format = TEXT;
    if (strFormat) {
        // 不正値なら例外スロー(JSONException相当)
        format = [StringRequestParamSpec parseFormat: strFormat];
    }
    [builder format: format];
    
    // maxLength
    if (strMaxLength) {
        if ([DConnectRequestParamSpec isDigit: strMaxLength]) {
            NSNumber *maxLength = [[NSNumber alloc] initWithInt: [strMaxLength intValue]];
            [builder maxLength: maxLength];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"maxLength is invalid : %@", strMaxLength];
        }
    }
    
    // minLength
    if (strMinLength) {
        if ([DConnectRequestParamSpec isDigit: strMinLength]) {
            NSNumber *minLength = [[NSNumber alloc] initWithInt: [strMinLength intValue]];
            [builder minLength: minLength];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"minLength is invalid : %@", strMinLength];
        }
    }
    
    // enumJson
    if (enumArray) {
        if (![enumArray isKindOfClass: [NSArray class]]) {
            @throw @"enum not array";
        }
        [builder enumList: (NSArray *)enumArray];
    }
    
    // buildしてJSONを返す
    return [builder build];
}

@end
