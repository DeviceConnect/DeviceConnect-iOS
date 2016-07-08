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


@end
