//
//  DPThetaRoiDeliveryContext.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/21.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPThetaRoiDeliveryContext.h"
#import "DPThetaGLRenderView.h"


static float const DPThetaNS2S = 1.0f / 1000000000.0f;
static const double DPThetaMotionDeviceIntervalMilliSec = 100;

@interface DPThetaRoiDeliveryContext()
@property (nonatomic) NSMutableArray *deltaRotationVector;
@property (nonatomic) long lastEventTimestamp;
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


@end

@implementation DPThetaRoiDeliveryContext


- (instancetype)initWithSource:(DPThetaOmnidirectionalImage *)source callback:(void(^)())callback
{
    CMMotionManager *motionMgr = [CMMotionManager new];

    self = [super init];
    if (self) {
        _source = source;
        _deltaRotationVector = [[NSMutableArray alloc] initWithCapacity:4];
        _motionManager = motionMgr;
        _motionManager.deviceMotionUpdateInterval = DPThetaMotionDeviceIntervalMilliSec / 1000.0;
        _deviceOrientationOpQueue = [NSOperationQueue new];
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
        _glRenderView = NULL;
    }
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = NULL;
    }
}


- (void)changeRenderParameter:(DPThetaParam *)parameter isUserRequest:(BOOL)isUserRequest
{
    int width = parameter.imageWidth;
    int height = parameter.imageHeight;
    if (isUserRequest) {
        // TODO: ステレオ画像の生成処理の追加
        if (parameter.vrMode) {
            [self startVrMode];
        } else {
            [self stopVrMode];
        }
    }
    _currentParam = parameter;
    
    DPThetaCameraBuilder *builder = [[DPThetaCameraBuilder alloc] init];
    [builder setPosition:[[DPThetaVector3D alloc] initWithX:(float)parameter.cameraX
                                                         y:(float)parameter.cameraY * -1
                                                          z:(float)parameter.cameraZ]];
    if (isUserRequest) {
        [builder rotateByEulerAngleForRoll:(float)parameter.cameraRoll
                                       yaw:(float)parameter.cameraYaw
                                     pitch:(float)parameter.cameraPitch];
    }
    builder.fovDegree = (float)parameter.cameraFOV;
    _glRenderView.camera = builder.create;
//    [_glRenderView setSphereRadius:parameter.sphereSize];
    _glRenderView.screenWidth = parameter.imageWidth;
    _glRenderView.screenHeight = parameter.imageHeight;
    [self render];
}



- (void)startVrMode
{
    [_motionManager startDeviceMotionUpdatesToQueue:_deviceOrientationOpQueue
                                            withHandler:_deviceOrientationOp];
}

- (void)stopVrMode
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void) sendDeviceOrientationEventWithMotion:(CMDeviceMotion *)motion
{

//    if (_lastEventTimestamp != 0) {
        float dT = (motion.timestamp - _lastEventTimestamp) * DPThetaNS2S;
        _eventInterval += dT;
        double coef = 180 / M_PI;
        float axisX = (coef * motion.rotationRate.x);
        float axisY = (coef * motion.rotationRate.y);
        float axisZ = (coef * motion.rotationRate.z);
        float omegaMagnitude = (float) sqrt(axisX * axisX + axisY * axisY + axisZ * axisZ);

    
        if (omegaMagnitude > 0) {
            axisX /= omegaMagnitude;
            axisY /= omegaMagnitude;
            axisZ /= omegaMagnitude;
        }
        
        float thetaOverTwo = omegaMagnitude * dT / 2.0f;
        float sinThetaOverTwo = (float) sin(thetaOverTwo);
        float cosThetaOverTwo = (float) cos(thetaOverTwo);
        
        _deltaRotationVector[0] = [NSNumber numberWithFloat:(sinThetaOverTwo * axisX)];
        _deltaRotationVector[1] = [NSNumber numberWithFloat:(sinThetaOverTwo * axisY)];
        _deltaRotationVector[2] = [NSNumber numberWithFloat:(sinThetaOverTwo * axisZ)];
        _deltaRotationVector[3] = [NSNumber numberWithFloat:cosThetaOverTwo];
       
        DPThetaQuaternion *q = [[DPThetaQuaternion alloc] initWithReal:[_deltaRotationVector[3] floatValue]
                                                             imaginary:
                                [[DPThetaVector3D alloc] initWithX:[_deltaRotationVector[2] floatValue] * -1
                                                                 y:[_deltaRotationVector[1] floatValue]
                                                                 z:[_deltaRotationVector[0] floatValue] * -1]];
        [_glRenderView rotateCameraWithQuaterion:q];
//        if (_eventInterval >= 0.01f) {
//            _eventInterval = 0;
            [self render];
//        }
//    }
//    _lastEventTimestamp = motion.timestamp;
}




- (void)render
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_glRenderView draw];
        int width = _currentParam.imageWidth;
        int height = _currentParam.imageHeight;
        UIImage *result = nil;

        if (_currentParam.stereoMode) {
            DPThetaCamera *center = _glRenderView.camera;
            float distance = 2.5f / 100.0f; //5cm
            NSArray *cameras = [_glRenderView.camera getCameraForStereoForDistance:distance];
            _glRenderView.camera = cameras[0];
            UIImage *left = _glRenderView.snapshot;
            _glRenderView.camera = cameras[1];
            UIImage *right = _glRenderView.snapshot;
            _glRenderView.camera = center;
            
            // TODO: UIImageの合成
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
    dispatch_async(dispatch_get_main_queue(), ^{
        _glRenderView = [[DPThetaGLRenderView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_glRenderView setTexture:_source.image
                              yaw:0.0f
                            pitch:0.0f
                             roll:0.0f];
        UIViewController *rootView = [UIApplication sharedApplication].keyWindow.rootViewController;
        CGRect viewSize = rootView.view.frame;
        while (rootView.presentedViewController) {
            rootView = rootView.presentedViewController;
        }
        [rootView.view addSubview:_glRenderView];
        _glRenderView.hidden = YES;
        [_glRenderView draw];
    });
    
}
@end
