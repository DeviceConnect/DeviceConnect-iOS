//
//  DPHueModelController.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueModelController.h"
#import "DPHueSettingViewControllerBase.h"
#import "DPHueConst.h"
#import "DPHueViewController.h"

@interface DPHueModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;
@property (nonatomic, weak) UIViewController *root;

@end

@implementation DPHueModelController

- (id)initWithRootViewController:(UIViewController *)root
{
    self = [super init];
    if (self) {
        // Create the data model.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        _pageData = [[dateFormatter monthSymbols] copy];
        _root = root;
    }
    return self;
}

- (DPHueSettingViewControllerBase *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Return the data view controller for the given index.
        if (([self.pageData count] == 0) || (index >= DPHUE_SETTING_PAGE_COUNT_IPHONE)) {
            return nil;
        }
    } else {
        // Return the data view controller for the given index.
        if (([self.pageData count] == 0) || (index >= DPHUE_SETTING_PAGE_COUNT_IPAD)) {
            return nil;
        }
    }
    NSString *viewId = [NSString stringWithFormat:@"DPHueSettingViewController%lu", (unsigned long)(index + 1)];
    
    // Create a new view controller and pass suitable data.
    DPHueSettingViewControllerBase *viewController = [storyboard instantiateViewControllerWithIdentifier:viewId];
    
    viewController.objectIndex = index;
    
    viewController.hueViewController = self.hueViewController;
    viewController.root = self.root;

    return viewController;
}

- (NSUInteger)indexOfViewController:(DPHueSettingViewControllerBase *)viewController
{
    return viewController.objectIndex;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
}

#pragma mark - Page View Controller Data Source

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return DPHUE_SETTING_PAGE_COUNT_IPHONE;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    NSUInteger pageNo = [self indexOfViewController:
                         [pageViewController.viewControllers objectAtIndex:0]];

    return pageNo;
}

@end
