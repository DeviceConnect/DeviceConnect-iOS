//
//  InitialGuideViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "InitialGuideViewController.h"
#import "GuideDataViewController.h"

@interface InitialGuideViewController ()
{
    __weak UIPageViewController* pageview;
    InitialGuideViewModel *viewModel;
}
@end

@implementation InitialGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewModel = [[InitialGuideViewModel alloc]init];
    viewModel.delegate = self;

    pageview = (UIPageViewController*)[self.childViewControllers firstObject];
    pageview.delegate = self;
    pageview.dataSource = self;
    [pageview setViewControllers: @[[viewModel makeViewController: 0]]
                       direction: UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
}


- (void)dealloc
{
    viewModel = nil;
}

//--------------------------------------------------------------//
#pragma mark - pageViewController delegate
//--------------------------------------------------------------//
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(GuideDataViewController *)viewController
{
    NSInteger index = viewController.pageNumber;
    viewModel.pageIndex = index - 1;
    return [viewModel viewControllerAtIndex: viewModel.pageIndex];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(GuideDataViewController *)viewController
{
    NSInteger index = viewController.pageNumber;
    viewModel.pageIndex = index + 1;
    return [viewModel viewControllerAtIndex: viewModel.pageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return viewModel.datasource.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return viewModel.pageIndex;
}

//--------------------------------------------------------------//
#pragma mark - InitialGuideViewModelDelegate
//--------------------------------------------------------------//
- (void)closeWindow
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
