//
//  DPHitoeControlECGViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHitoeControlECGViewController.h"
#import "DPHitoeECGChartView.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeHeartData.h"
#import "DPHitoeManager.h"


static int const DPHitoeECGChartInterval = 40;
static int const DPHitoeECGChartMaxRange = 4800;
@interface DPHitoeControlECGViewController () {
    NSMutableArray *ecgList;
    long long minX;
    long long maxX;
}

@property (weak, nonatomic) IBOutlet DPHitoeECGChartView *ecgChart;
@property (nonatomic) NSTimer *ecgTimer;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ecgChartTop;

@end

@implementation DPHitoeControlECGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ecgChart.layer.borderColor = [[UIColor grayColor] CGColor];
    _ecgChart.layer.borderWidth = 1.0;
    ecgList = [NSMutableArray array];
    minX = 0;
    maxX = 0;
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
    title.text = @"ECG(心電図)";
    [title sizeToFit];
    self.navigationItem.titleView = title;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_ecgChart setupWithDataMax:4800 valueMin:-3000.0 valueMax:3000.0];
}
- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private method
- (void)startTimer {
    maxX = minX + DPHitoeECGChartMaxRange;
    [ecgList removeAllObjects];
    NSTimeInterval target = DPHitoeECGChartInterval / 1000;
    _ecgTimer = [NSTimer
              scheduledTimerWithTimeInterval:target
              target:self
              selector:@selector(onECGTimer:)
              userInfo:nil
              repeats:YES];
    
}

- (void)stopTimer {
    if (_ecgTimer.isValid) {
        [_ecgTimer invalidate];
    }
}


- (void)updateChart {
    [_ecgChart drawPointNow];
}

- (void)setECGWithIndex:(long long)index ecg:(double)ecg {
    if ([ecgList count] == 0) {
        minX = index;
        maxX = index + DPHitoeECGChartMaxRange;
    }
    
    if (index > maxX) {
        [ecgList removeAllObjects];
        minX = index;
        maxX = index + DPHitoeECGChartMaxRange;
    }
    CGPoint p = CGPointMake((CGFloat) index, (CGFloat) (ecg / 1000));
    [ecgList addObject:[NSValue valueWithCGPoint:p]];
 
    [_ecgChart drawPointWithIndex:(int) (index - minX) pulse:ecg];
}

#pragma mark - Timer
- (void)onECGTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeHeartRateData *heart = [mgr getECGDataForServiceId:super.device.serviceId];
    DPHitoeHeartData *data = heart.ecg;
    if (data) {
        [self setECGWithIndex:data.timeStamp ecg:data.value];
    }
    [_ecgChart drawPointNow];
}

#pragma mark - Listener
- (IBAction)registerECG:(id)sender {
    [self startTimer];
}
- (IBAction)unregisterECG:(id)sender {
    [self stopTimer];
}

#pragma mark - Rotate Delegate



- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _ecgChartTop.constant = 20;
    } else {
        _ecgChartTop.constant = 121;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
}

@end
