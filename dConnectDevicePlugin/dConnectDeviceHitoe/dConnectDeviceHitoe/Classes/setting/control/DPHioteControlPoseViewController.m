//
//  DPHioteControlPoseViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHioteControlPoseViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoePoseEstimationData.h"
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>

@interface DPHioteControlPoseViewController()
@property (weak, nonatomic) IBOutlet UIImageView *poseImageView;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poseImageTop;
@property (nonatomic) NSTimer *poseTimer;

@end
@implementation DPHioteControlPoseViewController
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
    title.text = @"PoseEstimation(姿勢推定)";
    [title sizeToFit];
    self.navigationItem.titleView = title;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
}

#pragma mark - Timer
- (void)onPoseTimer:(NSTimer *)timer {
    NSString *bundlePath  = [DPHitoeBundle() bundlePath];
    DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
    DPHitoePoseEstimationData *pose = [mgr getPoseEstimationDataForServiceId:super.device.serviceId];
    if (pose) {
        if ([pose.state isEqualToString:DCMPoseEstimationProfileStateBackward]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_backward.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceDown]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_facedown.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceLeft]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceleft.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceRight]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceright.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceUp]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceup.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateForward]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_forward.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateLeftside]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_leftside.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateRightside]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_rightside.png"]]];
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateStanding]) {
            [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_standing.png"]]];
        }
    }
}

#pragma mark - Private method
- (void)startTimer {
    
    _poseTimer = [NSTimer
                       scheduledTimerWithTimeInterval:1.0
                       target:self
                       selector:@selector(onPoseTimer:)
                       userInfo:nil
                       repeats:YES];
    
}

- (void)stopTimer {
    if (_poseTimer.isValid) {
        [_poseTimer invalidate];
    }
}

#pragma mark - Listener
- (IBAction)registerPoseEstimation:(id)sender {
    [self startTimer];
}
- (IBAction)unregisterPoseEstimation:(id)sender {
    [self stopTimer];
}

#pragma mark - Rotate Delegate

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _poseImageTop.constant = 5;
    } else {
        _poseImageTop.constant = 64;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
}

@end
