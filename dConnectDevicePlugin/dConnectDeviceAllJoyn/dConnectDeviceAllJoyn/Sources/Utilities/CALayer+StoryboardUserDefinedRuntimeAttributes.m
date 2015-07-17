//
//  CALayer+StoryboardUserDefinedRuntimeAttributes.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CALayer+StoryboardUserDefinedRuntimeAttributes.h"


@implementation CALayer (StoryboardUserDefinedRuntimeAttributes)

- (void)setBorderColorFromUIColor:(UIColor *)borderColor
{
    self.borderColor = borderColor.CGColor;
}

- (void)setBackgroundColorFromUIColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor.CGColor;
}

- (void)setShadowColorFromUIColor:(UIColor *)shadowColor
{
    self.shadowColor = shadowColor.CGColor;
}

@end
