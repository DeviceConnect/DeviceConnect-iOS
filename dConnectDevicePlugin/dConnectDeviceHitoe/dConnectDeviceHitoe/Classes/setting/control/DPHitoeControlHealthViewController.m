//
//  DPHitoeControlHealthViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeControlHealthViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeHeartData.h"

@interface DPHitoeControlHealthViewController ()
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heartRateImageTop;
@property (nonatomic) NSTimer *heartRateTimer;

@end

@implementation DPHitoeControlHealthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(_registerBtn);
    roundCorner(_unregisterBtn);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"HeartRate(心拍数)";
    [title sizeToFit];
    self.navigationItem.titleView = title;

}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Timer
- (void)onHeartRateTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeHeartRateData *heart = [mgr getHeartRateDataForServiceId:super.device.serviceId];
    DPHitoeHeartData *data = heart.heartRate;
    if (data) {
        [_heartRateLabel setText:[NSString stringWithFormat:@"%d", (int) data.value]];
    }
}

#pragma mark - Private method
- (void)startTimer {
    [_heartRateLabel setText:@"0"];

    _heartRateTimer = [NSTimer
                 scheduledTimerWithTimeInterval:1.0
                 target:self
                 selector:@selector(onHeartRateTimer:)
                 userInfo:nil
                 repeats:YES];
    
}

- (void)stopTimer {
    if (_heartRateTimer.isValid) {
        [_heartRateTimer invalidate];
    }
}

#pragma mark - Listener
- (IBAction)registerHeartRate:(id)sender {
    [self startTimer];
}
- (IBAction)unregisterHeartRate:(id)sender {
    [self stopTimer];
}

#pragma mark - Rotate Delegate

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _heartRateImageTop.constant = 5;
    } else {
        _heartRateImageTop.constant = 64;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
}


@end
