//
//  DPHitoeControlWalkViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeControlWalkViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoeWalkStateData.h"

@interface DPHitoeControlWalkViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet UILabel *step;
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *lrbalance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTop;
@property (nonatomic) NSTimer *walkTimer;

@end

@implementation DPHitoeControlWalkViewController

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
    title.text = @"WalkState(歩行状態)";
    [title sizeToFit];
    self.navigationItem.titleView = title;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Listener
#pragma mark - Timer
- (void)onWalkTimer:(NSTimer *)timer {
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoeWalkStateData *walk = [mgr getWalkStateDataForServiceId:super.device.serviceId];
    if (walk) {
        [_step setText:[NSString stringWithFormat:@"%d歩", walk.step]];
        [_state setText:[NSString stringWithFormat:@"%@", walk.state]];
        [_speed setText:[NSString stringWithFormat:@"%.2lfkm/s", walk.speed]];
        [_distance setText:[NSString stringWithFormat:@"%.2lfkm", walk.distance]];
        [_lrbalance setText:[NSString stringWithFormat:@"%.2lf", walk.balance]];
    }
}

#pragma mark - Private method
- (void)startTimer {
    
    _walkTimer = [NSTimer
                       scheduledTimerWithTimeInterval:1.0
                       target:self
                       selector:@selector(onWalkTimer:)
                       userInfo:nil
                       repeats:YES];
    
}

- (void)stopTimer {
    if (_walkTimer.isValid) {
        [_walkTimer invalidate];
    }
}

#pragma mark - Listener
- (IBAction)registerWalk:(id)sender {
    [self startTimer];
}
- (IBAction)unregisterWalk:(id)sender {
    [self stopTimer];
}

#pragma mark - Rotate Delegate

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _viewTop.constant = 5;
    } else {
        _viewTop.constant = 41;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _viewTop.constant = 10;
    } else {
        _viewTop.constant = 65;
    }
}


@end
