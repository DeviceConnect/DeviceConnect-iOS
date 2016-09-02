//
//  DConnectProfileSpecJsonParserFactory.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfileSpecJsonParserFactory.h"
#import "SwaggerJsonParserFactory.h"

@implementation DConnectProfileSpecJsonParserFactory

- (DConnectProfileSpecJsonParser *) createParser {
    return nil;
}

+ (DConnectProfileSpecJsonParserFactory *) getDefaultFactory {
    return [[SwaggerJsonParserFactory alloc] init];
}

@end
