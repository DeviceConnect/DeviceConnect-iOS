//
//  DPLinkingPairingViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingPairingViewController.h"

@interface DPLinkingPairingViewController ()

@end

@implementation DPLinkingPairingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.indicatorView startAnimating];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.indicatorView stopAnimating];
}

@end
