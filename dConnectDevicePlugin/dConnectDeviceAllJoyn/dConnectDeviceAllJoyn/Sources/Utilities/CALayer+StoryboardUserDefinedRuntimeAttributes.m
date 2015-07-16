//
//  CALayer+StoryboardUserDefinedRuntimeAttributes.m
//  AdhocCommunication
//
//  Copyright (c) 2015 NTT DOCOMO, Inc. All rights reserved.
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
