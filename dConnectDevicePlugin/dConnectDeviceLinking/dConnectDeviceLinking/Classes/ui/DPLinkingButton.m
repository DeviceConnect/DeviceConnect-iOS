//
//  DPLinkingButton.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingButton.h"

@implementation DPLinkingButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.layer.backgroundColor = self.highlitedBackgroundColor.CGColor;
    } else {
        self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
    }
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
    } else {
        self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
    }
}

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = self.cornerRadius;
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = self.borderWidth;

    if ([self isEnabled]) {
        self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
    } else {
        self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
        self.layer.borderColor = self.disabledBackgroundColor.CGColor;
    }

    [super drawRect:rect];
}

@end
