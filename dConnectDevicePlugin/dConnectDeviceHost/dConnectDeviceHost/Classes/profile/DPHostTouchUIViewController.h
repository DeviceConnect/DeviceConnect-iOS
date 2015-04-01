//
//  DPHostTouchUIViewController.h
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPHostTouchProfile.h"
#import "DPHostTouchView.h"

@interface DPHostTouchUIViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet DPHostTouchView *hostTouchView;

@end