//
//  SonyCameraDataViewController.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraDataViewController.h"

@interface SonyCameraDataViewController ()
@end

@implementation SonyCameraDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIScrollView *scrollView = (UIScrollView *)self.mainView;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0.0, 0.0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
