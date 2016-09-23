//
//  DPLinkingDeviceViewController.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPLinkingDeviceManager.h"

@interface DPLinkingDeviceViewController : UITableViewController

@property (nonatomic) DPLinkingDeviceManager *deviceManager;
@property (nonatomic) DPLinkingDevice *device;

@end
