//
//  DPIRKitVirtualDeviceViewController.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import "DPIRKitDevice.h"

@interface DPIRKitVirtualDeviceViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) id provider;
@property (strong, nonatomic) id detailName;
@end
