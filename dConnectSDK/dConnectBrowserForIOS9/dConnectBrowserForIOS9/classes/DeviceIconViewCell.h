//
//  DeviceIconViewCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import "DeviceIconViewModel.h"

@interface DeviceIconViewCell : UICollectionViewCell
typedef void (^DidDeviceIconSelected)(DConnectMessage*);

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIImageView *typeIconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) DeviceIconViewModel *viewModel;
@property (copy, nonatomic) DidDeviceIconSelected didIconSelected;

- (void)setDevice:(DConnectMessage*)message;
- (void)setEnabled:(BOOL)isEnabled;
@end
