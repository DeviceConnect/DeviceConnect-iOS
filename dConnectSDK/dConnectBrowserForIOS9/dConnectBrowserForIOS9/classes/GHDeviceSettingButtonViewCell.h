//
//  GHDeviceSettingButtonViewCell.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidTappedSetting)();
@interface GHDeviceSettingButtonViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (nonatomic, copy) DidTappedSetting didTappedSetting;
@end
