//
//  DPAWSIoTDeviceListViewController.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPAWSIoTDeviceListViewController : UIViewController
@property (nonatomic, weak) id<DConnectSystemProfileDelegate> delegate;

@end
