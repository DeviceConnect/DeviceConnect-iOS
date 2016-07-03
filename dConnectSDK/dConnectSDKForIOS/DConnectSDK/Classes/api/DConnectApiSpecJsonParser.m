//
//  DConnectApiSpecJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpecJsonParser.h"
#import "DConnectApiSpec.h"
#import "DConnectApiSpecBuilder.h"

#import "DConnectRequestParamSpecJsonParser.h"
#import "DConnectRequestParamSpec.h"


@implementation DConnectApiSpecJsonParser

// androidのDConnectApiSpec#fromJson()相当。(DConnectApiSpecの中に置くのは#importの関係で難しいのでDConnectApiJsonParserを作成して実装した)
+ (DConnectApiSpec *) fromJson : (NSDictionary *)apiObj {
    
    NSString *name = [apiObj objectForKey:DConnectApiSpecJsonKeyName];
    NSString *path = [apiObj objectForKey:DConnectApiSpecJsonKeyPath];
    NSString *methodStr = [apiObj objectForKey:DConnectApiSpecJsonKeyMethod];
    NSString *typeStr = [apiObj objectForKey:DConnectApiSpecJsonKeyType];
    
    @try {
        
        // 認識できない文字列を渡したら例外をスローする
        DConnectApiSpecMethod method = [DConnectApiSpec parseMethod: methodStr];
        
        // 認識できない文字列を渡したら例外をスローする
        DConnectApiSpecType type = [DConnectApiSpec parseType: typeStr];
        
        NSMutableArray *paramList = [NSMutableArray array]; // DConnectRequestParamSpecの配列
        NSArray *requestParams = [apiObj objectForKey: DConnectApiSpecJsonKeyRequestParams]; // NSDictionaryの配列
        if (requestParams != nil) {
            for (int k = 0; k < [requestParams count]; k ++) {
                NSDictionary *paramObj = [requestParams objectAtIndex: k];
                @try {
                    DConnectRequestParamSpec *paramSpec = [DConnectRequestParamSpecJsonParser fromJson: paramObj];
                    if (paramSpec != nil) {
                        [paramList addObject: paramSpec];
                    }
                }
                @catch (NSString *e) {
                    NSLog(@"%@", e);
                    DCLogE(e);
                }
            }
        }
        DConnectApiSpecBuilder *builder = [[DConnectApiSpecBuilder alloc] init];
        
        DConnectApiSpec *apiSpec = [[[[[[builder name: name] type: type] method: method] path: path] requestParamSpecList: paramList] build];
        return apiSpec;
    }
    @catch (NSString *e) {
        DCLogE(@"fromJson exception: %@", e);
        return nil;
    }
}

@end
