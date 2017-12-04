//
//  GHDeviceSettingButtonViewCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

typedef void (^DidTappedSetting)(void);
@interface GHDeviceSettingButtonViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (nonatomic, copy) DidTappedSetting didTappedSetting;
@end
