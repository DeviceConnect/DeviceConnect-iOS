//
//  DPHitoeControlStressViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeControlStressViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoeStressEstimationData.h"

@interface DPHitoeControlStressViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet UILabel *stressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stressTop;
@property (nonatomic) NSTimer *stressTimer;
@property (weak, nonatomic) IBOutlet UIView *stressView;


@end

@implementation DPHitoeControlStressViewController

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
    title.text = @"StressEstimation(ストレス推定)";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    [self initLFHFView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Timer
- (void)onStressTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeStressEstimationData *stress = [mgr getStressEstimationDataForServiceId:super.device.serviceId];

    if (stress) {
        
        if (stress.timeStamp == -1) {
            return;
        }
        
        
        CAGradientLayer *lc = [_stressView.layer valueForKey:@"colorLayer"];
        
        NSString *labelValue = [NSString stringWithFormat:@"LF/HF %.2f", stress.lfhf];
        _stressLabel.text = labelValue;
        
        lc.frame = _stressView.bounds;
        
        // グラデーションの混合範囲は 0.2 中間値を２とする
        float lfhfLevel = (float) stress.lfhf / 4.0;  // 0.0 - 0.6
        
        lc.hidden = NO;
        lc.locations = @[@(lfhfLevel - 0.1), @(lfhfLevel + 0.1)];
    }
}

#pragma mark - Private method
- (void)startTimer {
    _stressTimer = [NSTimer
                       scheduledTimerWithTimeInterval:1.0
                       target:self
                       selector:@selector(onStressTimer:)
                       userInfo:nil
                       repeats:YES];
    
}

- (void)stopTimer {
    if (_stressTimer.isValid) {
        [_stressTimer invalidate];
    }
}

- (void)initLFHFView {
    CAGradientLayer *stressColorLayer = [CAGradientLayer layer];
    UIColor *lfColor  = [UIColor colorWithRed:1.0 green:0.48 blue:0.50 alpha:1];
    UIColor *hfColor  = [UIColor colorWithRed:0.77 green:0.99 blue:0.70 alpha:1];
    
    stressColorLayer.colors = @[(id)lfColor.CGColor, (id)hfColor.CGColor];
    stressColorLayer.locations = @[@(1), @(1)];
    stressColorLayer.hidden = YES;
    stressColorLayer.frame = _stressView.bounds;
    stressColorLayer.startPoint = CGPointMake(1.0, 0.5);
    stressColorLayer.endPoint = CGPointMake(0.0, 0.5);
    
    [_stressView.layer insertSublayer:stressColorLayer atIndex: 0];
    
    [_stressView.layer setValue:stressColorLayer forKey:@"colorLayer"];
    
    _stressView.layer.borderColor = [UIColor grayColor].CGColor;
    _stressView.layer.borderWidth = 1.0;
    
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
        _stressTop.constant = 10;
    } else {
        _stressTop.constant = 127;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _stressTop.constant = 10;
    } else {
        _stressTop.constant = 95;
    }
}


@end
