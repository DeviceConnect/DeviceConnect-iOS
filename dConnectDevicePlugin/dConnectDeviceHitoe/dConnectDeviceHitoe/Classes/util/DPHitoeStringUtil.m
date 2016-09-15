//
//  DPHitoeStringUtil.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeStringUtil.h"

@implementation DPHitoeStringUtil

+ (int)lastIndexOf:(NSString*)str c:(NSString*)c {
    NSRange range=[str rangeOfString:c
                             options:NSCaseInsensitiveSearch|NSBackwardsSearch];
    if (range.location==NSNotFound) {
        return -1;
    }
    return (int) range.location;
}
@end
