//
//  DeviceMoreViewCell.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidDeviceMorelected)();

@interface DeviceMoreViewCell : UICollectionViewCell
@property (nonatomic, copy) DidDeviceMorelected didDeviceMorelected;
@end
