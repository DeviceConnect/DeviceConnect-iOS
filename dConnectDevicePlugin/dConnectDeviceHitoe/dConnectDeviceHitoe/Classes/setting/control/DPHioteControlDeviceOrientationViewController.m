//
//  DPHioteControlDeviceOrientationViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHioteControlDeviceOrientationViewController.h"
#import "DPHitoeACCChartView.h"
#import "DPHitoeManager.h"
#import "DPHitoeAccelerationData.h"

static int const DPHitoeACCInterval = 120;

static int const DPHitoeACCMaxRange = 4800;

@interface DPHioteControlDeviceOrientationViewController () {
    NSMutableArray *accList;
    long long minX;
    long long maxX;
}
@property (weak, nonatomic) IBOutlet DPHitoeACCChartView *accChartView;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartViewTop;
@property (nonatomic) NSTimer *accTimer;

@end

@implementation DPHioteControlDeviceOrientationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _accChartView.layer.borderColor = [[UIColor grayColor] CGColor];
    _accChartView.layer.borderWidth = 1.0;
    accList = [NSMutableArray array];
    minX = 0;
    maxX = 0;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_accChartView setupWithDataMax:4800 valueMin:-4.0 valueMax:4.0];
}
- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}

#pragma mark - Private method
- (void)startTimer {
    maxX = minX + DPHitoeACCMaxRange;
    [accList removeAllObjects];
    NSTimeInterval target = DPHitoeACCInterval / 1000;
    _accTimer = [NSTimer
                 scheduledTimerWithTimeInterval:target
                 target:self
                 selector:@selector(onACCTimer:)
                 userInfo:nil
                 repeats:YES];
    
}

- (void)stopTimer {
    if (_accTimer.isValid) {
        [_accTimer invalidate];
    }
}


- (void)updateChart {
    [_accChartView drawPointNow];
}

- (void)setAccWithData:(DPHitoeAccelerationData*)accel {
    if ([accList count] == 0) {
        minX = accel.timeStamp;
        maxX = accel.timeStamp + DPHitoeACCMaxRange;
    }
    
    if (accel.timeStamp > maxX) {
        [accList removeAllObjects];
        minX = accel.timeStamp;
        maxX = accel.timeStamp + DPHitoeACCMaxRange;
    }
    [accList addObject:accel];
    
    [_accChartView drawPointWithIndex:(int) (accel.timeStamp - minX) pulse:accel];
}

#pragma mark - Timer
- (void)onACCTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeAccelerationData *accel = [mgr getAccelerationDataForServiceId:super.device.serviceId];
    if (accel) {
        [self setAccWithData:accel];
    }
    [_accChartView drawPointNow];
}

#pragma mark - Listener
- (IBAction)registerAccel:(id)sender {
    [self startTimer];
}
- (IBAction)unregisterAccel:(id)sender {
    [self stopTimer];
}

#pragma mark - Rotate Delegate



- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _chartViewTop.constant = 20;
    } else {
        _chartViewTop.constant = 121;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
}


@end
