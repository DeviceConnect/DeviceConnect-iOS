//
//  DeviceMoreViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "DeviceMoreViewCell.h"

@implementation DeviceMoreViewCell

//--------------------------------------------------------------//
#pragma mark - ボタン制御
//--------------------------------------------------------------//
- (IBAction)didTapItem:(UIButton *)sender {
    self.didDeviceMorelected();
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
    self.didDeviceMorelected = nil;
}

@end
