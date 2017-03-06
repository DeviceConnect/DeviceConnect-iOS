//
//  DPHueModelController.h
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPHueViewController.h"

@class DPHueSettingViewControllerBase;
@class DPHueDevicePlugin;

@interface DPHueModelController : NSObject <UIPageViewControllerDataSource>

@property (atomic) DPHueViewController *hueViewController;


- (id) initWithRootViewController:(UIViewController *)root;

/*!
 指定されたインデックスに対応するViewControllerを返却する。
 
 @param[in] index ページ数
 @param[in] storyboard ViewControllerが格納されたストーリーボード
 
 @retval ViewControllerのインスタンス
 @retval nil ページが存在しない場合
 */
- (DPHueSettingViewControllerBase *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;

/*!
 brief 指定されたViewControllerのページ数を取得する。
 
 @param[in] viewController ページ数が知りたいViewController
 
 @return ページ数
 */
- (NSUInteger)indexOfViewController:(DPHueSettingViewControllerBase *)viewController;

@end
