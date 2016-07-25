//
//  DPHitoeControlBatteryViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeControlBatteryViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeTargetDeviceData.h"
#import "DPHitoeConsts.h"
@interface DPHitoeControlBatteryViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UIButton *batteryBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *batteryImageTop;

@end

@implementation DPHitoeControlBatteryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(_batteryBtn);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"Battery(電池残量)";
    [title sizeToFit];
    self.navigationItem.titleView = title;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Listener
- (IBAction)getBattery:(id)sender {
    NSString *bundlePath  = [DPHitoeBundle() bundlePath];
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeHeartRateData *heart = [mgr getHeartRateDataForServiceId:super.device.serviceId];
    DPHitoeTargetDeviceData *data = heart.target;
    if (data) {
        float level = (data.batteryLevel + 1) / 4;
        if (level == 1.0) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery01.png"]]];
            } else {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery01_960.png"]]];
            }
        } else if (level == 0.75) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery02.png"]]];
            } else {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery02_960.png"]]];
            }
        } else if (level == 0.5) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery03.png"]]];
            } else {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery03_960.png"]]];
            }
        } else if (level == 0.25) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery04.png"]]];
            } else {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery04_960.png"]]];
            }
        } else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery05.png"]]];
            } else {
                [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery05_960.png"]]];
            }
        }
        [_batteryLabel setText:[NSString stringWithFormat:@"%d", (int) (level * 100)]];
    }
}

#pragma mark - Rotate Delegate

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _batteryImageTop.constant = 5;
    } else {
        _batteryImageTop.constant = 63;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _batteryImageTop.constant = 10;
    } else {
        _batteryImageTop.constant = 70;
    }
}

@end
