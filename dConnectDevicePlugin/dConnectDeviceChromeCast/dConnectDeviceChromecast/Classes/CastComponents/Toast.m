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

#import "Toast.h"

static const CGFloat kToastHorizontalMarginFraction = 0.05f;
static const CGFloat kToastBottomMarginFraction = 0.05f;
static const CGFloat kToastHeightFraction = 0.1f;

// Coordinate to ensure two toasts are never active at once.
static BOOL isToastActive;

@interface Toast ()

@property (nonatomic) UILabel *messageLabel;

@end

@implementation Toast

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self removeFromSuperview];
  isToastActive = false;
}

+ (void)displayToastInView:(UIView*)hostView
               withMessage:(NSString*)message
          forTimeInSeconds:(float)timeInSeconds {

  if (!isToastActive) {

    isToastActive = YES;

    // Compute toast frame dimensions.
    CGFloat hostHeight = hostView.frame.size.height;
    CGFloat hostWidth = hostView.frame.size.width;
    CGFloat horizontalOffset = hostWidth * kToastHorizontalMarginFraction;
    CGFloat toastHeight = hostHeight * kToastHeightFraction;
    CGFloat toastWidth = hostWidth - (2 * horizontalOffset);
    CGFloat verticalOffset = hostHeight - (toastHeight + (hostHeight * kToastBottomMarginFraction));
    CGRect toastRect = CGRectMake(horizontalOffset, verticalOffset, toastWidth, toastHeight);

    // Init and stylize the toast and message.
    Toast *toast = [[Toast alloc] initWithFrame:toastRect];
    toast.backgroundColor = [UIColor colorWithRed:71.0/255.0
                                            green:92.0/255.0
                                             blue:109.0/255.0
                                            alpha:0.9];
    toast.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, toastWidth, toastHeight)];
    toast.messageLabel.text = message;
    toast.messageLabel.textColor = [UIColor whiteColor];
    toast.messageLabel.textAlignment = NSTextAlignmentCenter;
    toast.messageLabel.font = [UIFont systemFontOfSize:18];
    toast.messageLabel.adjustsFontSizeToFitWidth = YES;

    // Put the toast on top of the host view
    [toast addSubview:toast.messageLabel];
    [hostView insertSubview:toast aboveSubview:[hostView.subviews lastObject]];

    // Set the toast's timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInSeconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                     [toast removeFromSuperview];
                     isToastActive = NO;
                   });
  }
}

@end
