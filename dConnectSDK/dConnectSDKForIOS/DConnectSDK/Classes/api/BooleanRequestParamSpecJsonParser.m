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
    NSString *strIsMandatory = [jsonObj objectForKey:BooleanRequestParamSpecJsonKeyIsMandatory];
    if (name == nil || strIsMandatory == nil) {
        return nil;
    }
    
    BOOL isMandatory;
    if ([strIsMandatory localizedCaseInsensitiveCompare:BooleanRequestParamSpecJsonValTrue] == NSOrderedSame) {
        isMandatory = TRUE;
    } else if ([strIsMandatory localizedCaseInsensitiveCompare: BooleanRequestParamSpecJsonValFalse] == NSOrderedSame) {
        isMandatory = FALSE;
    } else {
        return nil;
    }
    
    BooleanRequestParamSpecBuilder *builder = [[BooleanRequestParamSpecBuilder alloc] init];
    
    BooleanRequestParamSpec *paramSpec = [[[builder name: name] isMandatory: isMandatory] build];
    return paramSpec;
}

@end
