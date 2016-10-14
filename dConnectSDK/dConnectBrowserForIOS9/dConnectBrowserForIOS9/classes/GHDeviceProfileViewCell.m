//
//  GHDeviceProfileViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceProfileViewCell.h"

@implementation GHDeviceProfileViewCell

- (void)configureCell:(DConnectProfile *)profile
{
    self.titleLabel.text = [profile profileName];
}

@end
