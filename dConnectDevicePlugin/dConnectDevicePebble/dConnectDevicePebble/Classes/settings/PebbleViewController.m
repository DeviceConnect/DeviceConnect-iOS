//
//  PebbleViewController.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "PebbleViewController.h"
#import "PebbleModelController.h"
#import "PebbleDataViewController.h"
#import "pebble_device_plugin_defines.h"

@interface PebbleViewController ()
@property (readonly, strong, nonatomic) PebbleModelController *PebbleModelController;
@end

@implementation PebbleViewController

@synthesize PebbleModelController = _PebbleModelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    self.pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
    self.pageViewController.delegate = self;
    
    PebbleDataViewController *startingViewController
            = [self.PebbleModelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    self.pageViewController.dataSource = self.PebbleModelController;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];


    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    NSArray *subviews = self.pageViewController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([subviews[i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *) subviews[i];
        }
    }
    thisControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.1 green:0.5 blue:1.0 alpha:1.0];
    thisControl.pageIndicatorTintColor =[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        thisControl.numberOfPages = SETTING_PAGE_COUNT_IPHNE;
    } else {
        thisControl.numberOfPages = SETTING_PAGE_COUNT_IPAD;
    }
    

    
    [self.pageViewController didMoveToParentViewController:self];
    
     // Add the page view controller's gesture recognizers to
     // the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PebbleModelController *)PebbleModelController
{
    if (!_PebbleModelController) {
        _PebbleModelController = [[PebbleModelController alloc] init];
    }
    return _PebbleModelController;
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)
        || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    PebbleDataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.PebbleModelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.PebbleModelController pageViewController:self.pageViewController
                                                            viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController
                = [self.PebbleModelController
                                            pageViewController:self.pageViewController
                            viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    
    return UIPageViewControllerSpineLocationMid;
}


#pragma mark - action methods

- (IBAction)closeBtnDidPushed:(id)sender {
    // 完了ボタンを押したときに閉じるように設定
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
