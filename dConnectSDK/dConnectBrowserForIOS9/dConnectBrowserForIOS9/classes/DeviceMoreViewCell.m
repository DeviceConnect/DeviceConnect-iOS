//
//  DeviceMoreViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
