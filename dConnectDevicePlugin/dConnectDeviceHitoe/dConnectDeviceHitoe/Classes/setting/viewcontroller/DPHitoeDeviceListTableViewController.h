//
//  DPHitoeDeviceListTableViewController.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeManager.h"
@interface DPHitoeDeviceListTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate>
@property (nonatomic, weak) id<DConnectSystemProfileDelegate> delegate;

@end
