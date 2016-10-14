//
//  GHDeviceSettingButtonViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceSettingButtonViewCell.h"

@implementation GHDeviceSettingButtonViewCell

- (void)layoutSubviews
{
    self.settingButton.layer.cornerRadius = 10;
    self.settingButton.clipsToBounds = YES;
}

- (IBAction)didTappedButton:(UIButton *)sender {
    if (_didTappedSetting) {
        _didTappedSetting();
    }
}
- (IBAction)didTouchDown:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.settingButton.alpha = 0.5;
    }];
}

- (IBAction)didTouchUp:(id)sender {
    self.settingButton.alpha = 1.0;
}

- (void)dealloc
{
    _didTappedSetting = nil;
}

@end
