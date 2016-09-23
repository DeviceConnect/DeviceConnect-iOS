//
//  DeviceIconViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
    self.iconImage.image = self.viewModel.iconImage;
    if(self.viewModel.typeIconFilename) {
        self.typeIconImage.image = [UIImage imageNamed:self.viewModel.typeIconFilename];
        self.typeIconImage.hidden = NO;
    } else {
        self.typeIconImage.hidden = YES;
    }
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

- (IBAction)backNormal:(UIButton *)sender {
    self.alpha = 1.0;
}

- (void)dealloc
{
    self.didIconSelected = nil;
}

@end
