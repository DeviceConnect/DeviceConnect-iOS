//
//  DevicePluginViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "DevicePluginViewCell.h"

@implementation DevicePluginViewCell

- (void)layoutSubviews
{
    self.iconView.layer.cornerRadius = 10;
    self.iconView.clipsToBounds = YES;
}

- (void)configureCell:(DConnectDevicePlugin*)plugins
{

}

@end
