//
//  GHDevicePluginViewCell.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface GHDevicePluginViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (void)configureCell:(DConnectDevicePlugin*)plugins;

@end
