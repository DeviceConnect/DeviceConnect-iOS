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
@property (nonatomic) NSTimer *timer;
@property (nonatomic, copy) DPHitoeDevice *device;

@end

@implementation DPHitoeControlECGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ecgChart.layer.borderColor = [[UIColor grayColor] CGColor];
    _ecgChart.layer.borderWidth = 1.0;
    ecgList = [NSMutableArray array];
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
    minX = 0;
    maxX = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_ecgChart setupWithDataMax:4800 valueMin:-3000.0 valueMax:3000.0];
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

#pragma mark - Private method
- (void)startTimer {
    maxX = minX + DPHitoeECGChartMaxRange;
    [ecgList removeAllObjects];
    NSTimeInterval target = DPHitoeECGChartInterval / 1000;
    _timer = [NSTimer
              scheduledTimerWithTimeInterval:target
              target:self
              selector:@selector(onTimer:)
              userInfo:nil
              repeats:YES];
    
}

- (void)stopTimer {
    if (_timer.isValid) {
        [_timer invalidate];
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
    NSLog(@"ecg:%d", [ecgList count]);
    NSLog(@"index:%ld", index);
    NSLog(@"minxX:%ld", minX);
    NSLog(@"max:%ld", maxX);
    [_ecgChart drawPointWithIndex:(int) (index - minX) pulse:ecg];
}

#pragma mark - Timer
- (void)onTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeHeartRateData *heart = [mgr getECGDataForServiceId:_device.serviceId];
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

@end