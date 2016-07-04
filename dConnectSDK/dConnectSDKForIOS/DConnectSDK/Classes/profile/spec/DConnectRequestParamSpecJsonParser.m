//
//  DConnectRequestParamSpecJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRequestParamSpecJsonParser.h"
#import "BooleanRequestParamSpecJsonParser.h"
#import "StringRequestParamSpecJsonParser.h"
#import "IntegerRequestParamSpecJsonParser.h"
#import "NumberRequestParamSpecJsonParser.h"

@implementation DConnectRequestParamSpecJsonParser

+ (DConnectRequestParamSpec *)fromJson: (NSDictionary *) json {
    
    NSString *type = [json objectForKey: DConnectRequestParamSpecJsonKeyType];
    
    @try {
        // 失敗したら例外を返す
        DConnectRequestParamSpecType paramType = [DConnectRequestParamSpec parseType: type];
        
        DConnectRequestParamSpec *spec = nil;
        switch (paramType) {
            case BOOLEAN:
                spec = [BooleanRequestParamSpecJsonParser fromJson: json];
                break;
            case STRING:
                spec = [StringRequestParamSpecJsonParser fromJson: json];
                break;
            case INTEGER:
                spec = [IntegerRequestParamSpecJsonParser fromJson: json];
                break;
            case NUMBER:
                spec = [NumberRequestParamSpecJsonParser fromJson: json];
                break;
            default:
                @throw [NSString stringWithFormat: @"Unknown requestParamType: %@", type];
        }
        return spec;
    }
    @catch (NSString *e) {
        @throw e;
    }
}

@end
