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
    
    __weak DeviceIconViewCell* _self = self;
    self.alpha = 0.3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _self.alpha = 1.0;
    });
}

- (IBAction)backNormal:(UIButton *)sender {
    self.alpha = 1.0;
}

- (void)dealloc
{
    self.didIconSelected = nil;
}

@end
