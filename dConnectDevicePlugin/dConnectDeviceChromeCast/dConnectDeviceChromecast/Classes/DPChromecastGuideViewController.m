//
//  DPChromecastGuideViewController.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastGuideViewController.h"
#import "DPChromecastManager.h"
#import "CastDeviceController.h"
#import "NotificationConstants.h"
#import "SimpleImageFetcher.h"
#import <GoogleCast/GCKDeviceManager.h>
#import <GoogleCast/GCKMediaControlChannel.h>


@interface DPChromecastGuideViewController (){
    DPChromecastManager *_manager;
}
@end

@implementation DPChromecastGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)rulButtonPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString: @"http://www.google.com/chromecast/setup"];
    [[UIApplication sharedApplication] openURL:url];
}



@end
