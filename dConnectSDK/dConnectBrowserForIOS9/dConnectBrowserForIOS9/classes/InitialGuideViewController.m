//
//  InitialGuideViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "InitialGuideViewController.h"
#import "GuideDataViewController.h"

@interface InitialGuideViewController ()
{
    __weak UIPageViewController* pageview;
    InitialGuideViewModel *viewModel;
    UIButton* closeButton;
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

    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"close_button"];
    [closeButton setImage:image forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateButtonFrame];
}

- (void)updateButtonFrame
{
    CGSize buttonSize = CGSizeMake(44, 44);
    closeButton.frame = CGRectMake(self.view.frame.size.width - 20 - buttonSize.width,
                                   20,
                                   buttonSize.width,
                                   buttonSize.height);
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
