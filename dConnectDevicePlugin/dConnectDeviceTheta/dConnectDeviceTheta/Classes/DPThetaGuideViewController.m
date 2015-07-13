//
//  DPThetaGuideViewController.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//



#import "DPThetaGuideViewController.h"
#import "DPThetaManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface DPThetaGuideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@end

@implementation DPThetaGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 角丸にする
    self.searchBtn.layer.cornerRadius = 16;
    
    self.ssidLabel.text = @"Not Found Theta.";
}



#pragma mark - Action methods

- (IBAction) searchBtnDidPushed:(id)sender
{
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.progressView.hidden = NO;
    self.progressView.layer.cornerRadius = 20;
    self.progressView.clipsToBounds = true;
    [self.indicator startAnimating];
    dispatch_async(updateQueue, ^{
        if ([[DPThetaManager sharedManager] connect]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ssidLabel.text = @"Theta Connected.";
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ssidLabel.text = @"Not Found Theta.";
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            [self.indicator stopAnimating];
        });
    });
}

@end
