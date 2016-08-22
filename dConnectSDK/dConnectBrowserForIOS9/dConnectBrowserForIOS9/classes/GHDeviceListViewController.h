//
//  GHDeviceListViewController.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHDeviceListViewModel.h"
@interface GHDeviceListViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, GHDeviceListViewModelDelegate>

@end
