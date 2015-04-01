//
//  TabViewController.m
//  dConnectSDKSample
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ((UITabBarItem *)self.tabBar.items[0]).title = @"デバッガ";
    ((UITabBarItem *)self.tabBar.items[1]).title = @"ブラウザ";
}

@end
