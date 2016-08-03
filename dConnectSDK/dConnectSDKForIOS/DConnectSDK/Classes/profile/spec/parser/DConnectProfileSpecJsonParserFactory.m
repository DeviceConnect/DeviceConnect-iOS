//
//  DConnectProfileSpecJsonParserFactory.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/29.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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
