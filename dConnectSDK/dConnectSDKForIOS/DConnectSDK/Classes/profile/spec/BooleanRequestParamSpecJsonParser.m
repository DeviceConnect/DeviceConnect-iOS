//
//  BooleanRequestParamSpecParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanRequestParamSpecJsonParser.h"
#import "BooleanRequestParamSpecBuilder.h"

@implementation BooleanRequestParamSpecJsonParser

// androidのBooleanRequestParamSpec#fromJson()相当。(BooleanRequestParamSpecの中に置くのは#importの関係で難しいのでBooleanRequestParamSpecJsonParserを作成して実装した)
+ (BooleanRequestParamSpec *) fromJson : (NSDictionary *)jsonObj {
    
    NSString *name = [jsonObj objectForKey:BooleanRequestParamSpecJsonKeyName];
    NSNumber *numMandatory = [jsonObj objectForKey:BooleanRequestParamSpecJsonKeyIsMandatory];
    
    BooleanRequestParamSpecBuilder *builder = [[BooleanRequestParamSpecBuilder alloc] init];
    
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
    
    // buildしてJSONを返す
    return [builder build];
}

@end
