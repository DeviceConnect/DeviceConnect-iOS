//
//  DevicePluginViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDevicePluginViewCell.h"

@implementation GHDevicePluginViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews
{
    self.iconView.layer.cornerRadius = 10;
    self.iconView.clipsToBounds = YES;
}

- (void)configureCell:(DConnectDevicePlugin*)plugins
{
    self.titleLabel.text = [plugins pluginName];
    self.versionLabel.text = [plugins pluginVersionName];
    self.iconView.image = [self iconImage:plugins];
}

- (UIImage*)iconImage:(DConnectDevicePlugin*)plugins
{
    NSString* filePath = [plugins iconFilePath:YES]; //NOTE:DConnectDevicePluginではonlineかどうかわからない
    if (filePath) {
        return [[UIImage alloc] initWithContentsOfFile:filePath];
    } else {
        return [UIImage imageNamed:@"default_device_icon"];
    }
}

@end
