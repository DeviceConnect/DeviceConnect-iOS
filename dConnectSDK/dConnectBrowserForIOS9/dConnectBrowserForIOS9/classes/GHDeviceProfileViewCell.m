//
//  GHDeviceProfileViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "GHDeviceProfileViewCell.h"

@implementation GHDeviceProfileViewCell

- (void)configureCell:(DConnectProfile *)profile
{
    self.titleLabel.text = [profile profileName];
}

@end
