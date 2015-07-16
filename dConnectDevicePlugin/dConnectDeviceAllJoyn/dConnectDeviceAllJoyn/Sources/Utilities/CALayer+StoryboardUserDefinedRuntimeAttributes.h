//
//  CALayer+StoryboardUserDefinedRuntimeAttributes.h
//  AdhocCommunication
//
//  Copyright (c) 2015 NTT DOCOMO, Inc. All rights reserved.
//

@import UIKit;
@import QuartzCore;


@interface CALayer (StoryboardUserDefinedRuntimeAttributes)

- (void)setBorderColorFromUIColor:(UIColor *)borderColor;
- (void)setBackgroundColorFromUIColor:(UIColor *)backgroundColor;
- (void)setShadowColorFromUIColor:(UIColor *)shadowColor;

@end
