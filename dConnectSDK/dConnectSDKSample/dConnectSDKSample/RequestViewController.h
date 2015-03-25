//
//  RequestViewController.h
//  dConnectSDKSample
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

@interface RequestViewController : UIViewController

@property (nonatomic, copy) DConnectMessage *service;

@end
