//
//  GHDeviceProfileViewCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface GHDeviceProfileViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)configureCell:(DConnectProfile *)profile;
@end
