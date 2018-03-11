//
//  DPIRKitPageViewController.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@class DPIRKitSettingViewController;

@interface DPIRKitPageViewController : UIViewController

@property (nonatomic) NSUInteger index;
@property (nonatomic, weak) DPIRKitSettingViewController *root;

- (void) setScrollEnable:(BOOL)enable;
- (void) setScrollEnable:(BOOL)enable closeBtn:(BOOL)closeEnable;

- (void) transitToNext;

@end
