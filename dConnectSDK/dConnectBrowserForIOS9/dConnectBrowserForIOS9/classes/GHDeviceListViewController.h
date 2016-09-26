//
//  GHDeviceListViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import "GHDeviceListViewModel.h"
@interface GHDeviceListViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, GHDeviceListViewModelDelegate>

@end
