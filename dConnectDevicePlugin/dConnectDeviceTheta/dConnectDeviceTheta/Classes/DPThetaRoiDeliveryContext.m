//
//  DPThetaRoiDeliveryContext.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaRoiDeliveryContext.h"
#import "DPThetaGLRenderView.h"

static const double DPThetaMotionDeviceIntervalMilliSec = 100;

@interface DPThetaRoiDeliveryContext()
@property (nonatomic) NSMutableArray *deltaRotationVector;
@property (nonatomic) float lastEventTimestamp;
@property (nonatomic) float eventInterval;
// 加速度センサー、ジャイロセンサーからの値受領を管理するオブジェクト
@property CMMotionManager *motionManager;
// motionManagerで使うキュー
@property NSOperationQueue *deviceOrientationOpQueue;
// キューで回す処理
@property (strong) CMDeviceMotionHandler deviceOrientationOp;
@property (strong) DPThetaOmnidirectionalImage *source;
@property (nonatomic) UIImage *stereoImage;
@property (strong) DPThetaGLRenderView *glRenderView;

@property (nonatomic) DPThetaQuaternion *currentRotation;
@property (nonatomic) NSTimer *timer;
@end

@implementation DPThetaRoiDeliveryContext


- (instancetype)initWithSource:(DPThetaOmnidirectionalImage *)source callback:(void(^)())callback
{
    CMMotionManager *motionMgr = [CMMotionManager new];

    self = [super init];
    if (self) {
        _source = source;
        _eventInterval = 0.0f;
        _deltaRotationVector = [[NSMutableArray alloc] initWithCapacity:4];
        _motionManager = motionMgr;
        _motionManager.deviceMotionUpdateInterval = DPThetaMotionDeviceIntervalMilliSec / 1000.0;
        _deviceOrientationOpQueue = [NSOperationQueue new];
        _currentRotation = [[DPThetaQuaternion alloc] initWithReal:1 imaginary:[[DPThetaVector3D alloc] initWithX:0 y:0 z:0]];
         __unsafe_unretained typeof(self) weakSelf = self;
        _deviceOrientationOp = ^(CMDeviceMotion *motion, NSError *error) {
            if (error) {
                NSLog(@"DPTheta Sensor Error:\n%@", error.description);
                [weakSelf.motionManager stopDeviceMotionUpdates];
            }
            [weakSelf sendDeviceOrientationEventWithMotion:motion];
        };
        
        [self initGL];
        if (callback) {
            callback();
        }
        
    }
    return self;
}

- (void)destroy
{
    if (_glRenderView) {
        [self removeGLView];
    }
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = NULL;
    }
}


- (void)changeRenderParameter:(DPThetaParam *)parameter isUserRequest:(BOOL)isUserRequest
{
    if (isUserRequest) {
        if (parameter.vrMode) {
            [self startVrMode];
        } else {
            [self stopVrMode];
        }
    }
    _currentParam = parameter;
    
    DPThetaCameraBuilder *builder = [[DPThetaCameraBuilder alloc] init];
    [builder setPosition:[[DPThetaVector3D alloc] initWithX:(float)parameter.cameraX
                                                         y:(float)(parameter.cameraY * -1)
                                                          z:(float)parameter.cameraZ]];
    if (isUserRequest) {
        [builder rotateByEulerAngleForRoll:(float)parameter.cameraRoll
                                       yaw:(float)parameter.cameraYaw
                                     pitch:(float)(parameter.cameraPitch * -1)];
    }
    builder.fovDegree = (float)parameter.cameraFOV;
    _glRenderView.camera = (DPThetaCamera *) builder.create;
    [_glRenderView setSphereRadius:parameter.sphereSize];
    _glRenderView.screenWidth = parameter.imageWidth;
    _glRenderView.screenHeight = parameter.imageHeight;
    [self render];
}



- (void)startVrMode
{
    _currentRotation = [[DPThetaQuaternion alloc] initWithReal:1 imaginary:[[DPThetaVector3D alloc] initWithX:0 y:0 z:0]];
    [_motionManager startDeviceMotionUpdatesToQueue:_deviceOrientationOpQueue
                                            withHandler:_deviceOrientationOp];
}

- (void)stopVrMode
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void) sendDeviceOrientationEventWithMotion:(CMDeviceMotion *)motion
{
    if (_lastEventTimestamp != 0) {
        float EPSILON = 0.000000001f;
        float vGyroscope[3];
        float deltaVGyroscope[4];
        DPThetaQuaternion *qGyroscopeDelta;
        float dT = motion.timestamp - _lastEventTimestamp;
        vGyroscope[0] = motion.rotationRate.z * -1;
        vGyroscope[1] = motion.rotationRate.y;
        vGyroscope[2] = motion.rotationRate.x;
        float omegaMagnitude = (float) sqrt(pow(vGyroscope[0], 2) + pow(vGyroscope[1], 2) + pow(vGyroscope[2], 2));
        if (omegaMagnitude > EPSILON) {
            vGyroscope[0] /= omegaMagnitude;
            vGyroscope[1] /= omegaMagnitude;
            vGyroscope[2] /= omegaMagnitude;
        }
        float thetaOverTwo = omegaMagnitude * dT / 2.0f;
        float sinThetaOverTwo = (float) sin(thetaOverTwo);
        float cosThetaOverTwo = (float) cos(thetaOverTwo);

        deltaVGyroscope[0] = (sinThetaOverTwo * vGyroscope[0]);
        deltaVGyroscope[1] = (sinThetaOverTwo * vGyroscope[1]);
        deltaVGyroscope[2] = (sinThetaOverTwo * vGyroscope[2]);
        deltaVGyroscope[3] = cosThetaOverTwo;
        
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationPortrait:
                qGyroscopeDelta = [[DPThetaQuaternion alloc] initWithReal:deltaVGyroscope[3]
                                                                imaginary:[[DPThetaVector3D alloc] initWithX:deltaVGyroscope[0]
                                                                                                           y:deltaVGyroscope[1]
                                                                                                           z:deltaVGyroscope[2]]];
                break;
            case UIInterfaceOrientationLandscapeLeft:
                qGyroscopeDelta = [[DPThetaQuaternion alloc] initWithReal:deltaVGyroscope[3]
                                                                imaginary:[[DPThetaVector3D alloc] initWithX:deltaVGyroscope[0]
                                                                                                           y:deltaVGyroscope[2] * -1
                                                                                                           z:deltaVGyroscope[1]]];
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                qGyroscopeDelta = [[DPThetaQuaternion alloc] initWithReal:deltaVGyroscope[3]
                                                                imaginary:[[DPThetaVector3D alloc] initWithX:deltaVGyroscope[0]
                                                                                                           y:deltaVGyroscope[1] * -1
                                                                                                           z:deltaVGyroscope[2] * -1]];
                break;
            case UIInterfaceOrientationLandscapeRight:
                qGyroscopeDelta = [[DPThetaQuaternion alloc] initWithReal:deltaVGyroscope[3]
                                                                imaginary:[[DPThetaVector3D alloc] initWithX:deltaVGyroscope[0]
                                                                                                           y:deltaVGyroscope[2]
                                                                                                           z:deltaVGyroscope[1] * -1]];
                break;
            default:
                break;
        }
        
        _currentRotation = [qGyroscopeDelta multiplyWithQuaternion:_currentRotation];
        
        
        DPThetaCamera *camera = _glRenderView.camera;
        DPThetaCameraBuilder *newCamera = [[DPThetaCameraBuilder alloc] initWithCamera:camera];
        [newCamera rotateForQuaternion:_currentRotation];
        _glRenderView.camera = (DPThetaCamera *) [newCamera create];
        
        _eventInterval += dT;
        if (_eventInterval >= 0.1f) {
            _eventInterval = 0;
            [self render];
        }
    }
    _lastEventTimestamp = motion.timestamp;
}




- (void)render
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_glRenderView draw];
        UIImage *result = nil;

        if (_currentParam.stereoMode) {
            DPThetaCamera *center = _glRenderView.camera;
            float distance = 2.5f / 100.0f; //5cm
            NSArray *cameras = [_glRenderView.camera getCameraForStereoForDistance:distance];
            _glRenderView.camera = cameras[0];
            [_glRenderView draw];
            UIImage *left = [_glRenderView snapshot];
            _glRenderView.camera = cameras[1];
            [_glRenderView draw];
            UIImage *right = [_glRenderView snapshot];
            _glRenderView.camera = center;
            
            
            NSArray *images = @[left, right];
            CGSize size = CGSizeMake(left.size.width * 2, left.size.height);
            result = [self compositeImages:images size:size];
            
        } else {
            result = [_glRenderView snapshot];
        }
        NSData *roi = [[NSData alloc] initWithData:UIImageJPEGRepresentation(result, 1.0)];
        
        _roi = roi;
        if (_delegate && roi && _segment) {
            [_delegate didUpdateMediaWithSegment:_segment data:roi];
        }
    });
}


- (void)draw
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_glRenderView draw];
    });
}


- (void)initGL
{
    [self removeGLView];
    dispatch_async(dispatch_get_main_queue(), ^{
        _glRenderView = [[DPThetaGLRenderView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_glRenderView setTexture:_source.image];
        UIViewController *rootView = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootView.presentedViewController) {
            rootView = rootView.presentedViewController;
        }
        [rootView.view addSubview:_glRenderView];
        _glRenderView.hidden = YES;
    });
    
}


- (void)removeGLView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_glRenderView removeFromSuperview];
        _glRenderView = NULL;
    });
}
- (UIImage *)compositeImages:(NSArray *)array size:(CGSize)size
{
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(size, 0.f, 0);
    

    UIImage *left = array[0];
    CGRect leftRect = CGRectMake(0, 0, left.size.width, size.height);
    [left drawInRect:leftRect];
    UIImage *right = array[1];
    CGRect rightRect = CGRectMake( left.size.width, 0, size.width, size.height);
    [right drawInRect:rightRect];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)startExpiredTimer
{
    
     _timer = [NSTimer
                 scheduledTimerWithTimeInterval:10.0
                 target:self
                 selector:@selector(onStartExpireTimer:)
                 userInfo:nil
                 repeats:NO];
}

- (void)onStartExpireTimer:(NSTimer*)timer
{
    if (_delegate) {
        [_delegate didExpiredMediaWithSegment:_segment];
    }
}

- (void)stopExpiredTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = NULL;
    }
}

- (void)restartExpiredTimer
{
    [self stopExpiredTimer];
    [self startExpiredTimer];
}
@end
