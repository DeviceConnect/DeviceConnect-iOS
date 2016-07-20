//
//  GHDeviceProfileViewCell.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface GHDeviceProfileViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)configureCell:(DConnectProfile *)profile;
@end
