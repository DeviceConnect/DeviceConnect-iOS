//
//  SwaggerJsonParserFactory.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SwaggerJsonParserFactory.h"
#import "SwaggerJsonParser.h"

@implementation SwaggerJsonParserFactory

- (DConnectProfileSpecJsonParser *) createParser {
    return [[SwaggerJsonParser alloc] init];
}

@end
