//
//  DPIRKitModelController.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DPIRKitSettingViewController;

@interface DPIRKitModelController : NSObject<UIPageViewControllerDataSource>

- (id) initWithRootViewController:(DPIRKitSettingViewController *)root;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

@end
