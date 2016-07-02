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
    NSString *strMandatory = [json objectForKey: DConnectRequestParamSpecJsonKeyMandatory];
    NSString *strFormat = [json objectForKey: StringRequestParamSpecJsonKeyFormat];
    NSString *strMaxLength = [json objectForKey: StringRequestParamSpecJsonKeyMaxLength];
    NSString *strMinLength = [json objectForKey: StringRequestParamSpecJsonKeyMinLength];
    NSString *strEnumJson = [json objectForKey: StringRequestParamSpecJsonKeyEnum];
    
    // 不正値なら例外スロー(JSONException相当)
    BOOL isMandatory = [DConnectRequestParamSpec parseBool:strMandatory];
    
    StringRequestParamSpecFormat format = TEXT;
    if (strFormat) {
        // 不正値なら例外スロー(JSONException相当)
        format = [StringRequestParamSpec parseFormat: strFormat];
    }
    
    StringRequestParamSpecBuilder *builder = [[StringRequestParamSpecBuilder alloc] init];
    [builder name: name];
    [builder isMandatory: isMandatory];
    
    if (strMaxLength) {
        if ([DConnectRequestParamSpec isDigit: strMaxLength]) {
            NSNumber *maxLength = [[NSNumber alloc] initWithInt: [strMaxLength intValue]];
            [builder maxLength: maxLength];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"maxLength is invalid : %@", strMaxLength];
        }
    }
    if (strMinLength) {
        if ([DConnectRequestParamSpec isDigit: strMinLength]) {
            NSNumber *minLength = [[NSNumber alloc] initWithInt: [strMinLength intValue]];
            [builder minLength: minLength];
        } else {
            // 不正値なら例外スロー(JSONException相当)
            @throw [NSString stringWithFormat: @"minLength is invalid : %@", strMinLength];
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
