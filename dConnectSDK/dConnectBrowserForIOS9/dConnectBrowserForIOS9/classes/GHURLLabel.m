//
//  GHURLLabel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHURLLabel.h"

@implementation GHURLLabel

- (void)drawTextInRect:(CGRect)rect
{
    // top, left, bottom, right
    UIEdgeInsets insets = {0, 10, 0, 40};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
