//
//  InitialGuideViewController.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitialGuideViewModel.h"
@interface InitialGuideViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, InitialGuideViewModelDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
