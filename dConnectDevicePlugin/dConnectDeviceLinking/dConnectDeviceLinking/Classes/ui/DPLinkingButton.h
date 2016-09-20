//
//  DPLinkingButton.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface DPLinkingButton : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;

@property (nonatomic) IBInspectable UIColor *normalBackgroundColor;
@property (nonatomic) IBInspectable UIColor *highlitedBackgroundColor;
@property (nonatomic) IBInspectable UIColor *disabledBackgroundColor;

@end
