//
//  DeviceMoreViewCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>

typedef void (^DidDeviceMorelected)(void);

@interface DeviceMoreViewCell : UICollectionViewCell
@property (nonatomic, copy) DidDeviceMorelected didDeviceMorelected;
@end
