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
@property (nonatomic, copy) DPHitoeDevice *device;

@end

@implementation DPHitoeControlHealthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景白
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"＜CLOSE"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeSettings:) ];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(_registerBtn);
    roundCorner(_unregisterBtn);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)closeSettings:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public method
- (void)setDevice:(DPHitoeDevice*)device {
    _device = device;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    NSString *titleMessage = [NSString stringWithFormat:@"%@ 操作画面", _device.name];
    title.text = titleMessage;
    [title sizeToFit];
    self.navigationItem.titleView = title;
}


#pragma mark - Timer
- (void)onHeartRateTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeHeartRateData *heart = [mgr getECGDataForServiceId:_device.serviceId];
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


// View回転時
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self rotateOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)rotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self iphoneLayoutWithOrientation:toInterfaceOrientation];
    } else {
        [self ipadLayoutWithOrientation:toInterfaceOrientation];
    }
    [self.view setNeedsUpdateConstraints];
}

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
