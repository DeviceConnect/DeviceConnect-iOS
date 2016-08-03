//
//  SwaggerJsonParserFactory.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/29.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "SwaggerJsonParserFactory.h"
#import "SwaggerJsonParser.h"

@implementation SwaggerJsonParserFactory

- (DConnectProfileSpecJsonParser *) createParser {
    return [[SwaggerJsonParser alloc] init];
}

@end
