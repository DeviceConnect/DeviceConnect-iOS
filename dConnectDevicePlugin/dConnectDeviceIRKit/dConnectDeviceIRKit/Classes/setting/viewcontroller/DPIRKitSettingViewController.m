//
//  DPIRKitSettingViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitSettingViewController.h"
#import "DPIRKitModelController.h"
#import "DPIRKitConst.h"

@interface DPIRKitSettingViewController ()<UIPageViewControllerDelegate>
{
    UIPageViewController *_pageViewController;
    DPIRKitModelController *_modelController;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBtn;

- (void) removeUserDefaults;

@end

@implementation DPIRKitSettingViewController

- (void) transitToNextFromViewController:(UIViewController *)viewController
{
    UIViewController *nextPage = [_modelController pageViewController:_pageViewController
                                    viewControllerAfterViewController:viewController];
    NSArray *viewControllers = @[nextPage];
    
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self removeUserDefaults];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceIRKit_resources"
                                                           ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *settingsTitle = [bundle localizedStringForKey:@"IRKitSettingsTitle"
                                                      value:@"Settings"
                                                      table:@"Localizable"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = settingsTitle;
    [title sizeToFit];
    self.navigationItem.titleView = title;
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00 green:0.63 blue:0.91 alpha:1.0];

    _pageViewController
    = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                      navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                    options:nil];
    _pageViewController.delegate = self;
    
    _modelController = [[DPIRKitModelController alloc] initWithRootViewController:self];
    UIViewController *firstPage = [_modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[firstPage];
    
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES completion:nil];
    _pageViewController.dataSource = _modelController;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    for (UIView *view in _pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            UIPageControl *control = (UIPageControl *) view;
            control.currentPageIndicatorTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            control.pageIndicatorTintColor =[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
            break;
        }
    }
    
    _pageViewController.view.frame = self.view.frame;
    [_pageViewController didMoveToParentViewController:self];
    self.view.gestureRecognizers = _pageViewController.gestureRecognizers;
}

- (void) removeUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:DPIRKitUDKeySSID];
    [userDefaults removeObjectForKey:DPIRKitUDKeySecType];
    [userDefaults removeObjectForKey:DPIRKitUDKeyPassword];
    [userDefaults removeObjectForKey:DPIRKitUDKeyDeviceKey];
    [userDefaults removeObjectForKey:DPIRKitUDKeyServiceId];
    [userDefaults synchronize];
}

- (IBAction)closeBtnDidPushed:(id)sender {
    [self removeUserDefaults];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDelegate

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    UIViewController *currentViewController = _pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
    
    _pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}


@end
