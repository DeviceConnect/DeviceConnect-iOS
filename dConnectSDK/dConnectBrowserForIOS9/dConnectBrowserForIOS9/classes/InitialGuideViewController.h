//
//  InitialGuideViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "InitialGuideViewModel.h"
@interface InitialGuideViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, InitialGuideViewModelDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
