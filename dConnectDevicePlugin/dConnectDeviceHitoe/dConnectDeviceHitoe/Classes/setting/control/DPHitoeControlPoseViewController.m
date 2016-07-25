//
//  DPHitoeControlPoseViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeControlPoseViewController.h"
#import "DPHitoeManager.h"
#import "DPHitoePoseEstimationData.h"
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>

@interface DPHitoeControlPoseViewController()
@property (weak, nonatomic) IBOutlet UIImageView *poseImageView;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *unregisterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poseImageTop;
@property (nonatomic) NSTimer *poseTimer;

@end
@implementation DPHitoeControlPoseViewController
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
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_backward.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_backward960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceDown]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_facedown.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_facedown960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceLeft]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceleft.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceleft960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceRight]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceright.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceright960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateFaceUp]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceup.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_faceup960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateForward]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_forward.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_forward960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateLeftside]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_leftside.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_leftside960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateRightside]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_rightside.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_rightside960.png"]]];
            }
        } else if ([pose.state isEqualToString:DCMPoseEstimationProfileStateStanding]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_standing.png"]]];
            } else {
                [_poseImageView setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"pose_standing960.png"]]];
            }
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
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _poseImageTop.constant = 10;
    } else {
        _poseImageTop.constant = 64;
    }

}

@end
