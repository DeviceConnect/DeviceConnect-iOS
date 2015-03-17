//
//  DConnectAddOriginViewController.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DConnectOriginInfo.h"

typedef NS_ENUM(NSUInteger, DConnectEditOriginMode) {
    DConnectEditOriginModeNew,
    DConnectEditOriginModeChange
};

@interface DConnectEditOriginViewController : UIViewController

@property IBOutlet UITextField *titleField;
@property IBOutlet UITextField *originField;
@property DConnectOriginInfo *originInfo;
@property DConnectEditOriginMode mode;

@end
