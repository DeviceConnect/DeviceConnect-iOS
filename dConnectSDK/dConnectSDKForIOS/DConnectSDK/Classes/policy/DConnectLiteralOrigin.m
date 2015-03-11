//
//  DConnectLiteralOrigin.m
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectLiteralOrigin.h"

@interface DConnectLiteralOrigin ()
@property NSString *originExp;
@end

@implementation DConnectLiteralOrigin

- (id) initWithString:(NSString *)originExp
{
    self = [super init];
    if (self) {
        _originExp = originExp;
    }
    return self;
}

- (BOOL) matches:(id<DConnectOrigin>)origin
{
    if (![origin isKindOfClass:[DConnectLiteralOrigin class]]) {
        return NO;
    }
    return [_originExp isEqualToString:((DConnectLiteralOrigin*) origin).originExp];
}

- (NSString *) stringify
{
    return _originExp;
}

@end