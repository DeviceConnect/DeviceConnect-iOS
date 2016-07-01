//
//  DeviceIconViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "DeviceIconViewCell.h"

@implementation DeviceIconViewCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.viewModel = [[DeviceIconViewModel alloc]init];
    }
    return self;
}

- (void)layoutSubviews
{
    self.iconImage.layer.cornerRadius = 10;
    self.iconImage.clipsToBounds = YES;
}

- (void)setDevice:(DConnectMessage*)message
{
    self.iconImage.image = nil;
    self.viewModel.message = message;
    self.titleLabel.text = self.viewModel.name;
    self.iconImage.image = [UIImage imageNamed:@"no_bookmark_icon"];
//
//    __weak BookmarkIconViewCell* weakSelf = self;
//    [self.viewModel bookmarkIconImage:^(UIImage *image) {
//        weakSelf.iconImage.image = image;
//        if (image.size.height < 32) {
//            weakSelf.iconImage.contentMode = UIViewContentModeCenter;
//        } else {
//            weakSelf.iconImage.contentMode = UIViewContentModeScaleAspectFit;
//        }
//    }];

    [self setEnabled:YES];
}

- (void)setEnabled:(BOOL)isEnabled
{
    self.iconImage.hidden = !isEnabled;
    self.titleLabel.hidden = !isEnabled;
    self.selectButton.enabled = isEnabled;
}


//--------------------------------------------------------------//
#pragma mark - ボタン制御
//--------------------------------------------------------------//
- (IBAction)didTapItem:(UIButton *)sender {
    self.didIconSelected(self.viewModel.message);
    self.alpha = 1.0;
}

- (IBAction)didTouchDown:(UIButton *)sender {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0.3;
    }];
}


- (void)dealloc
{
    self.didIconSelected = nil;
}

@end
