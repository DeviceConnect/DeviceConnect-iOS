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

- (void)dealloc
{
    _didTappedSetting = nil;
}

@end
