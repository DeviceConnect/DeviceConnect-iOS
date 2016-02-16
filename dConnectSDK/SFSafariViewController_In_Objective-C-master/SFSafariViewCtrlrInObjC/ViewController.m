//
//  ViewController.m
//  SFSafariViewCtrlrInObjC
//
//  Created by Suraj on 30/09/15.
//  Copyright © 2015 Suraj. All rights reserved.
//
#import "ViewController.h"
#import <DConnectSDK/DConnectSDK.h>
#import <SafariServices/SafariServices.h>

@interface ViewController () {
    SFSafariViewController *sfSafariViewController;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DConnectManager *mgr = [DConnectManager sharedManager];
    [mgr startByHttpServer];
//    [mgr startWebsocketByHttpServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];

    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        sfSafariViewController.delegate = self;
        [self presentViewController:sfSafariViewController animated:YES completion:nil];
    };
//    NSURL *url = [NSURL URLWithString:@"http://192.168.2.114:8000/d/index.html"];
    NSURL *url = [NSURL URLWithString:@"http://test.gclue.io/dwa/checker/"];
    loadSFSafariViewControllerBlock(url);
}

#pragma mark - SFSafariViewController Delegate Methods
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Load finished
    if (didLoadSuccessfully) {
        NSLog(@"SafariViewController: Loading of URl finished");
    }
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"safariViewController: Done button pressed");
    [sfSafariViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
