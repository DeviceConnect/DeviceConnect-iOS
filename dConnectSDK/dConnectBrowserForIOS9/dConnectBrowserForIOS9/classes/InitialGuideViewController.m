//
//  InitialGuideViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "InitialGuideViewController.h"
#import "InitialGuideViewModel.h"

@interface InitialGuideViewController ()
{
    __weak UIPageViewController* pageview;
    InitialGuideViewModel *viewModel;
}
@end

@implementation InitialGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageview = (UIPageViewController*)[self.childViewControllers firstObject];
    pageview.delegate = self;
    pageview.dataSource = self;
}


- (void)dealloc
{
    viewModel = nil;
}

//--------------------------------------------------------------//
#pragma mark - pageViewController delegate
//--------------------------------------------------------------//
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = viewModel.pageIndex;
    return [viewModel viewControllerAtIndex: index--];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = viewModel.pageIndex;
    return [viewModel viewControllerAtIndex: index++];
}

@end
