//
//  CALayer+StoryboardUserDefinedRuntimeAttributes.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

@import UIKit;


@interface CALayer (StoryboardUserDefinedRuntimeAttributes)

- (void)setBorderColorFromUIColor:(UIColor *)borderColor;
- (void)setBackgroundColorFromUIColor:(UIColor *)backgroundColor;
- (void)setShadowColorFromUIColor:(UIColor *)shadowColor;

@end
