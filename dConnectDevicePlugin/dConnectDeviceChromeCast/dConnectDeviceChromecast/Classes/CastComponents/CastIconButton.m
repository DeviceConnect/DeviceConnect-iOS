// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CastIconButton.h"

/**
 *  How long the Cast connecting animation should take to loop.
 */
static const int kCastIconButtonAnimationDuration = 2;

@interface CastIconButton ()

/**
 *  The image containing the empty cast icon.
 */
@property(nonatomic) UIImage *castOff;
/**
 *  The image with the filled cast icon.
 */
@property(nonatomic) UIImage *castOn;
/**
 *  The loop of images for animating.
 */
@property(nonatomic) NSArray *castConnecting;

@end

@implementation CastIconButton

/**
 *  Convenience method for creating a button.
 *
 *  @param frame The frame rectangle for the button.
 *
 *  @return A ready to use CastIconButton.
 */
+ (CastIconButton *)buttonWithFrame:(CGRect)frame {
  return [[CastIconButton alloc] initWithFrame:frame];
}

/**
 *  Designated initialiser. Create a new CastIconButton within the given frame.
 *
 *  @param frame Frame rectangle
 *
 *  @return a new CastIconButton
 */
- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
      NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
      NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

    self.castOff = [[UIImage imageNamed:@"cast_off" inBundle:bundle compatibleWithTraitCollection:nil]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.castOn = [[UIImage imageNamed:@"cast_on" inBundle:bundle compatibleWithTraitCollection:nil]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.castConnecting = @[[[UIImage imageNamed:@"cast_on0" inBundle:bundle compatibleWithTraitCollection:nil]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                            [[UIImage imageNamed:@"cast_on1" inBundle:bundle compatibleWithTraitCollection:nil]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                            [[UIImage imageNamed:@"cast_on2" inBundle:bundle compatibleWithTraitCollection:nil]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                            [[UIImage imageNamed:@"cast_on1" inBundle:bundle compatibleWithTraitCollection:nil]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.imageView.animationImages = self.castConnecting;
    self.imageView.animationDuration = kCastIconButtonAnimationDuration;
    self.status = CIBCastUnavailable;
  }
  return self;
}

/**
 *  Update the display of the button based on the status.
 *
 *  @param status The current status of the cast devices.
 */
- (void)setStatus:(CastIconButtonState)status {
  _status = status;
  switch (status) {
    case CIBCastUnavailable:
      [self.imageView stopAnimating];
      [self setHidden:YES];
      break;
    case CIBCastAvailable:
      [self setHidden:NO];
      [self.imageView stopAnimating];
      [self setImage:self.castOff forState:UIControlStateNormal];
      [self setTintColor:self.superview.tintColor];
      break;
    case CIBCastConnecting:
      [self setHidden:NO];
      [self.imageView startAnimating];
      [self setTintColor:self.superview.tintColor];
      break;
    case CIBCastConnected:
      [self setHidden:NO];
      [self.imageView stopAnimating];
      [self setImage:self.castOn forState:UIControlStateNormal];
      [self setTintColor:[UIColor yellowColor]];
      break;
  }
}

@end
