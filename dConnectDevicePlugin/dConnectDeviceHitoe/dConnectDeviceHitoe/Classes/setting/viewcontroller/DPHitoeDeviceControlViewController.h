//
//  DPHitoeDeviceControlViewController.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "DPHitoeDevice.h"
@interface DPHitoeDeviceControlViewController : UITableViewController<CBCentralManagerDelegate>


- (void)setDevice:(DPHitoeDevice*)device;
@end
