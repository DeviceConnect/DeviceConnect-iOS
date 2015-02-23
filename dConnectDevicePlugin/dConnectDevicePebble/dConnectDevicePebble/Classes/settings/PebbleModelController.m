//
//  PebbleModelController.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "PebbleModelController.h"
#import "PebbleDataViewController.h"
#import "pebble_device_plugin_defines.h"
#import "PebbleViewController.h"


@interface PebbleModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;

@end

@implementation PebbleModelController
- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        _pageData = [[dateFormatter monthSymbols] copy];
        
    }
    return self;
}

- (PebbleDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
 
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Return the data view controller for the given index.
        if (([self.pageData count] == 0) || (index >= SETTING_PAGE_COUNT_IPHNE)) {
            return nil;
        }
    } else {
        // Return the data view controller for the given index.
        if (([self.pageData count] == 0) || (index >= SETTING_PAGE_COUNT_IPAD)) {
            return nil;
        }
    }
    
    NSString *viewId = [NSString stringWithFormat:@"PebbleSettingView0%uController", (int)index + 1];
    
    // Create a new view controller and pass suitable data.
    PebbleDataViewController *PebbleDataViewController = [storyboard instantiateViewControllerWithIdentifier:viewId];
    PebbleDataViewController.objectIndex = index;
    PebbleDataViewController.deviceplugin = self.deviceplugin;
    return PebbleDataViewController;
}


- (NSUInteger)indexOfViewController:(PebbleDataViewController *)viewController
{   
    return viewController.objectIndex;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PebbleDataViewController *)viewController];
    if (index == 0) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PebbleDataViewController *)viewController];
    
    index++;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 7;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
