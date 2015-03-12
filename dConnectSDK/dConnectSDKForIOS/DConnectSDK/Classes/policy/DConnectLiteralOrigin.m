//
//  DConnectLiteralOrigin.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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