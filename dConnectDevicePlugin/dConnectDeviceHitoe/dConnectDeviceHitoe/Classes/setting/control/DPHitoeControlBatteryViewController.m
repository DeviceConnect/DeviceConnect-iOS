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
            [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery01.png"]]];
        } else if (level == 0.75) {
            [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery02.png"]]];
        } else if (level == 0.5) {
            [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery03.png"]]];
        } else if (level == 0.25) {
            [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery04.png"]]];
        } else {
            [_batteryImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"mark_battery05.png"]]];
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
}

@end