//
//  DPLinkingPopoverViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingPopoverViewController.h"
#import "DPLinkingMainViewController.h"

@interface DPLinkingPopoverViewController ()

@end

@implementation DPLinkingPopoverViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction) onClickSearchButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    UINavigationController *p = (UINavigationController *) self.presentingViewController;
    UIViewController *a = p.topViewController;
    [a performSegueWithIdentifier:@"search_linking_device" sender:self];
}

- (IBAction) onClickAppInfoButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UINavigationController *p = (UINavigationController *) self.presentingViewController;
    UIViewController *a = p.topViewController;
    [a performSegueWithIdentifier:@"device_plugin_info" sender:self];
}

- (IBAction) onClickDeleteAll:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UINavigationController *p = (UINavigationController *) self.presentingViewController;
    DPLinkingMainViewController *a = (DPLinkingMainViewController *) p.topViewController;
    [a openConfirmRemoveDeviceDialog];
}

@end
