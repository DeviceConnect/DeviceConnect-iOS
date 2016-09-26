//
//  GHDeviceSettingButtonViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
