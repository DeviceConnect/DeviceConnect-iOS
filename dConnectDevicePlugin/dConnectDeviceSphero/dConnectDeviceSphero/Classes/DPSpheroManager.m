//
//
//  DPSpheroManager.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroManager.h"
#import <RobotUIKit/RobotUIKit.h>
#import <RobotKit/RobotKit.h>
#import <DConnectSDK/DConnectService.h>
#import "DPSpheroService.h"
#import "DPSpheroLightService.h"

//LEDは色を変えられる
NSString *const kDPSpheroLED = @"1";
NSString *const kDPSpheroLEDName = @"Sphero LED";
//Calibrationは色を変えられない
NSString *const kDPSpheroCalibration = @"2";
NSString *const kDPSpheroCalibrationName = @"Sphero CalibrationLED";

// センサー監視間隔（400Hz/kSensorDivisor）
static int const kSensorDivisor = 40;
static NSString * const kDPSpheroRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const kDPSpheroRegexDigit = @"^([0-9]*)?$";
static NSString * const kDPSpheroMimeType = @"^([a-zA-Z]*)(/)([a-zA-Z]+)$";

static NSString * const CONNECTION_STATE = @"connectionState";
static NSString * const CONNECTION_STATE_ONLINE = @"online";
static NSString * const CONNECTION_STATE_OFFLINE = @"offline";

@interface DPSpheroManager ()

@end

@implementation DPSpheroManager
NSDate *_prevDate;
RKDataStreamingMask _streamingMask;
BOOL _startedCollisionSensor;
NSMutableDictionary *deviceList;
// 共有インスタンス
+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceSpheroToken;
    dispatch_once(&onceSpheroToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// 初期化
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初期状態で有効化済み
       _isActivated = YES;
       deviceList = [NSMutableDictionary dictionary];
    }
    return self;
}

// アプリがバックグラウンドに入った
- (void)applicationDidEnterBackground
{
    // センサーのマスクを保持
    _streamingMask = [RKSetDataStreamingCommand currentMask];
    [RKRobotDiscoveryAgent stopDiscovery];
    [RKRobotDiscoveryAgent disconnectAll];
    [[RKRobotDiscoveryAgent sharedAgent] removeNotificationObserver:self];
}

// アプリがフォアグラウンドに入った
- (void)applicationWillEnterForeground
{

    // すぐは復帰できないので。
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // hook up for robot state changes
        [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:_self selector:@selector(handleRobotStateChangeNotification:)];
        [RKRobotDiscoveryAgent startDiscovery];
    });
}

// 有効化
- (BOOL)activate
{
    return deviceList.count > 0;
}

// 無効化
- (void)deactivate
{
   _isActivated = NO;
}

// デバイスに接続
- (BOOL)connectDeviceWithID:(NSString*)serviceID
{
    if (!_isActivated) return NO;
    
    for (id key in [deviceList keyEnumerator]) {
        RKConvenienceRobot *device = deviceList[key];
        if ([device.robot.identifier isEqualToString:serviceID]) {
            
            // キャリブレーションLEDの明るさをリセット
            // FIXME: キャリブレーションLEDの明るさを取得する命令がないので、
            // LEDを付けたまま接続するとズレが生じる。
            _calibrationLightBright = 0;
            _streamingMask = 0;
            _startedCollisionSensor = NO;
             return YES;
        }
    }
    return NO;
}

// 接続可能なデバイスリスト取得
- (NSArray*)deviceList
{
    if (!_isActivated) return nil;
    return deviceList.mutableCopy;
}


// デバイス管理情報更新
- (void) updateManageServices {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.serviceProvider) {
            return;
        }
        
        // ServiceProviderに存在するサービスがdeviceListに存在する場合は、deviceのオンライン／オフライン状態を参照して設定する
        // 存在しない場合は、オフラインにする
        for (DConnectService *service in [self.serviceProvider services]) {
            NSString *serviceId = [service serviceId];
            BOOL isFindDevice = NO;
            BOOL isOnline = NO;
            for (id key in [deviceList keyEnumerator]) {
                RKConvenienceRobot *device = deviceList[key];
                NSString *deviceServiceId = device.robot.identifier;
                if (deviceServiceId && [serviceId localizedCaseInsensitiveCompare: deviceServiceId] == NSOrderedSame) {
                    isFindDevice = YES;
                    if ([device isConnected]) {
                        isOnline = YES;
                    } else {
                        isOnline = NO;
                    }
                    
                    break;
                }
            }
            if (isFindDevice) {
                [service setOnline: isOnline];
            } else {
                [service setOnline: NO];
            }
        }
        
        // サービス未登録なら登録する
        for (id key in [deviceList keyEnumerator]) {
            RKConvenienceRobot *device = deviceList[key];
            NSString *serviceId = device.robot.identifier;
            NSString *deviceName = device.robot.name;
            BOOL isOnline = NO;
            if ([device isConnected]) {
                isOnline = YES;
            } else {
                isOnline = NO;
            }
            
            DConnectService *service = [self.serviceProvider service: serviceId];
            if (service) {
                [service setOnline: isOnline];
            } else {
                service = [[DPSpheroService alloc] initWithServiceId:serviceId
                                                          deviceName:deviceName
                                                              plugin: self.plugin];
                [self.serviceProvider addService: service];
                [service setOnline: isOnline];
            }
            NSString *serviceIdForLED = [NSString stringWithFormat:@"%@_%@", serviceId, kDPSpheroLED];


            DConnectService *led = [self.serviceProvider service: serviceIdForLED];
            if (led) {
                [led setOnline: isOnline];
            } else {
                led = [[DPSpheroLightService alloc] initWithServiceId:serviceId
                                                              lightId:kDPSpheroLED
                                                          deviceName:kDPSpheroLEDName
                                                              plugin: self.plugin];
                [self.serviceProvider addService: led];
                [led setOnline: isOnline];
            }
            NSString *serviceIdForCalibration = [NSString stringWithFormat:@"%@_%@", serviceId, kDPSpheroCalibration];
            DConnectService *calibration = [self.serviceProvider service: serviceIdForCalibration];

            if (calibration) {
                [calibration setOnline: isOnline];
            } else {
                calibration = [[DPSpheroLightService alloc] initWithServiceId:serviceId
                                                                      lightId:kDPSpheroCalibration
                                                           deviceName:kDPSpheroCalibrationName
                                                               plugin: self.plugin];
                [self.serviceProvider addService: calibration];
                [calibration setOnline: isOnline];
            }
        }
    }
}

#pragma mark - Observer
- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    // Do not allow the robot to connect if the application is not running
    RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
    switch(n.type) {
        case RKRobotConnecting:
        break;
        case RKRobotOnline: {
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }
            deviceList[convenience.robot.identifier] = convenience;
            [self startSensor:_streamingMask divisor:kSensorDivisor serviceId:convenience.robot.identifier];
            if (_startedCollisionSensor) {
                [self startSensorCollisionForServiceId:convenience.robot.identifier];
            }
            __weak typeof(self) _self = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_self updateManageServices];
                // バックグラウンドから復帰した時にライトが光るため、再びファアグラウンドになったときのために一度消灯する。
                [self setLEDLightColor:[UIColor blackColor] serviceId:convenience.robot.identifier];
            });
            break;
        }
        case RKRobotDisconnected: {
            [self updateManageServices];
            dispatch_async(dispatch_get_main_queue(), ^{
                [RKRobotDiscoveryAgent startDiscovery];
            });
            break;
        }
        default:
        break;
    }
}

// レスポンスハンドラ
- (void)handleResponse:(RKDeviceResponse *)response
{
    if (!_isActivated) return;
    
    //NSLog(@"handleResponse:%@", response);
    // LEDライトの色を取得
    if ([NSStringFromClass([response class]) isEqualToString:@"RKGetUserRGBLEDColorResponse"]) {
        Byte red, green, blue;
        [response.responseData getBytes:&red range:NSMakeRange(0, 1)];
        [response.responseData getBytes:&green range:NSMakeRange(1, 1)];
        [response.responseData getBytes:&blue range:NSMakeRange(2, 1)];
        _LEDLightColor = [UIColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:1.0];
    }
}

// ストリーミングデータハンドラ
- (void)handleAsyncMessage:(RKAsyncMessage *)message forRobot:(id<RKRobotBase>)robot
{
    if (!_isActivated) return;
    
    if ([message isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        // 計測間隔
        int interval = [[NSDate date] timeIntervalSinceDate:_prevDate] * 1000;
        // Received sensor data
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)message;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];

        // Orientation
        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;
        RKGyroData *sensorGyroData = sensorsData.gyroData;
        if ((accelerometerData || sensorGyroData)
            && [_orientationDelegate respondsToSelector:@selector(spheroManagerStreamingOrientationForServiceId:gyroData:accel:interval:)]) {
            DPGyroData gyroData;
            gyroData.x = 0.1 * ((double) sensorGyroData.rotationRate.x);
            gyroData.y = 0.1 * ((double) sensorGyroData.rotationRate.y);
            gyroData.z = 0.1 * ((double) sensorGyroData.rotationRate.z);
            DPPoint3D accel;
            accel.x = accelerometerData.acceleration.x;
            accel.y = accelerometerData.acceleration.y;
            accel.z = accelerometerData.acceleration.z;
            [_orientationDelegate spheroManagerStreamingOrientationForServiceId:robot.identifier gyroData:gyroData accel:accel interval:interval];
        }
        // Quaternion
        RKQuaternionData *quaternionData = sensorsData.quaternionData;
        if (quaternionData
            && [_sensorDelegate respondsToSelector:@selector(spheroManagerStreamingQuaternionForServiceId:quaternion:interval:)]) {
            DPQuaternion quaternion;
            quaternion.q0 = quaternionData.quaternions.q0;
            quaternion.q1 = quaternionData.quaternions.q1;
            quaternion.q2 = quaternionData.quaternions.q2;
            quaternion.q3 = quaternionData.quaternions.q3;
            [_sensorDelegate spheroManagerStreamingQuaternionForServiceId:robot.identifier quaternion:quaternion interval:interval];
            //NSLog(@"qt:%f,%f,%f,%f", qt.q0, qt.q1, qt.q2, qt.q3);
        }
        // Locator
        RKLocatorData *locatorData = sensorsData.locatorData;
        if (locatorData
            && [_sensorDelegate respondsToSelector:@selector(spheroManagerStreamingLocatorForServiceId:pos:velocity:interval:)]) {
            CGPoint pos = CGPointMake(locatorData.position.x, locatorData.position.y);
            CGPoint vel = CGPointMake(locatorData.velocity.x, locatorData.velocity.y);
            [_sensorDelegate spheroManagerStreamingLocatorForServiceId:robot.identifier pos:pos velocity:vel interval:interval];
        }
        
        _prevDate = [NSDate date];
        
    } else if ([message isKindOfClass:[RKCollisionDetectedAsyncData class]]) {
        // Collision
        
        RKCollisionDetectedAsyncData *collisionData = (RKCollisionDetectedAsyncData *)message;
        if (collisionData
            && [_sensorDelegate respondsToSelector:
                @selector(spheroManagerStreamingCollisionForServiceId:impactAcceleration:axis:power:speed:time:)]) {
                DPPoint3D accel;
                accel.x = collisionData.impactAcceleration.x;
                accel.y = collisionData.impactAcceleration.y;
                accel.z = collisionData.impactAcceleration.z;
                CGPoint axis = CGPointMake(collisionData.impactAxis.x, collisionData.impactAxis.y);
                CGPoint power = CGPointMake(collisionData.impactPower.x, collisionData.impactPower.y);
                float speed = collisionData.impactSpeed;
                //collisionData.timeStamp; SDK側のデータを元に日付文字列を生成すると31年ずれる。
                //collisionData.impactTimeStampは0
                //Sphero側とスマートフォン側との差異が少ないためスマートフォン側の値を使用する。
                NSTimeInterval time = [NSDate date].timeIntervalSince1970;
                [_sensorDelegate spheroManagerStreamingCollisionForServiceId:robot.identifier
                                                            impactAcceleration:accel
                                                                          axis:axis
                                                                         power:power
                                                                         speed:speed
                                                                          time:time];
        }
    }
}


#pragma mark - Light

// キャリブレーションライトの点灯
- (void)setCalibrationLightBright:(float)calibrationLightBright serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    _calibrationLightBright = calibrationLightBright;
    RKConvenienceRobot *robot = deviceList[serviceId];
    
    [robot setBackLEDBrightness:_calibrationLightBright];
}

// LEDライトの色変更
- (void)setLEDLightColor:(UIColor*)color serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    _LEDLightColor = color;
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot setLEDWithRed:red * alpha
                   green:green * alpha
                    blue:blue * alpha];
}


// LEDが点灯しているか
- (BOOL)isLEDOn
{
    if (!_isActivated) return NO;
    
    CGFloat red, green, blue, alpha;
    [_LEDLightColor getRed:&red green:&green blue:&blue alpha:&alpha];
    //NSLog(@"led:%f, %f, %f", r, g, b);
    return red > 0 && green > 0 && blue > 0 && alpha > 0;
}


#pragma mark - Move

// 移動
- (void)move:(float)angle velocity:(float)velocity serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot driveWithHeading:angle andVelocity:velocity];
}

// 回転
- (void)rotate:(float)angle serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot driveWithHeading:angle andVelocity:0.0];
}

// 停止
- (void)stopWithServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;

    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot stop];
}


#pragma mark - Sensor

// 姿勢センサー開始
- (void)startSensorOrientationForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll
        | RKDataStreamingMaskIMUAnglesFilteredAll
        | RKDataStreamingMaskGyroXFiltered
        | RKDataStreamingMaskGyroYFiltered
        | RKDataStreamingMaskGyroZFiltered;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor serviceId:serviceId];
}

// 姿勢センサー停止
- (void)stopSensorOrientationForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll
    | RKDataStreamingMaskIMUAnglesFilteredAll
    | RKDataStreamingMaskGyroXFiltered
    | RKDataStreamingMaskGyroYFiltered
    | RKDataStreamingMaskGyroZFiltered;
    [self stopSensor:mask serviceId:serviceId];
}

// クォータニオンセンサー開始
- (void)startSensorQuaternionForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskQuaternionAll;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor serviceId:serviceId];
}

// クォータニオンセンサー停止
- (void)stopSensorQuaternionForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    [self stopSensor:RKDataStreamingMaskQuaternionAll serviceId:serviceId];
}

// 位置センサー開始
- (void)startSensorLocatorForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskLocatorAll;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor serviceId:serviceId];
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot sendCommand:[[RKConfigureLocatorCommand alloc] initForFlag:0 newX:0 newY:0 newYaw:0]];
}

// 位置センサー停止
- (void)stopSensorLocatorForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    [self stopSensor:RKDataStreamingMaskLocatorAll serviceId:serviceId];
}

// 衝突センサー開始
- (void)startSensorCollisionForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    _prevDate = [NSDate date];
    _startedCollisionSensor = YES;
    
    int xThreshold = 90;
    int yThreshold = 90;
    int xSpeedThreshold = 130;
    int ySpeedThreshold = 130;
    int deadZone = 1000;
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot sendCommand:[[RKConfigureCollisionDetectionCommand alloc] initForMethod:RKCollisionDetectionMethod1
                                                                        xThreshold:xThreshold
                                                                   xSpeedThreshold:xSpeedThreshold
                                                                        yThreshold:yThreshold
                                                                   ySpeedThreshold:ySpeedThreshold
                                                                  postTimeDeadZone:deadZone]];

    ////Register for asynchronise data streaming packets
    // TODO robotごとにセンサーを起動する
    [robot addResponseObserver:self];
    [robot enableCollisions:YES];
}

// 衝突センサー停止
- (void)stopSensorCollisionForServiceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    _startedCollisionSensor = NO;
    
    RKConvenienceRobot *robot = deviceList[serviceId];
    [robot enableCollisions:NO];
    
    [self stopSensor:0 serviceId:serviceId];
}

// 全センサー停止
- (void)stopAllSensor
{
    if (!_isActivated) return;
    
    _startedCollisionSensor = NO;
    for (NSString *key in [deviceList keyEnumerator]) {
        [deviceList[key] disableSensors];
        [deviceList[key] enableStabilization:YES];
    }
}

// センサー停止
- (void)stopSensor:(RKDataStreamingMask)mask serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    RKDataStreamingMask streamingMask = mask;
    // 指定のセンサーを外す
    if (streamingMask) {
        //NSLog(@"stopSensor_pre:%llx", mask);
        streamingMask = [RKSetDataStreamingCommand currentMask] & (0xFFFFFFFFFFFFFFFF^mask);
        //NSLog(@"stopSensor_after:%llx", mask);
    }
    RKConvenienceRobot *robot = deviceList[serviceId];
    if (!(streamingMask & RKDataStreamingMaskAccelerometerFilteredAll) &&
        !(streamingMask & RKDataStreamingMaskQuaternionAll)) {
        // 姿勢センサーとクォータニオンセンサーが無い場合はスタビライザーを再開
        [robot enableStabilization:YES];
    }

    if (streamingMask == RKDataStreamingMaskOff) {
        if (!_startedCollisionSensor) {
            // Turn off data streaming
            
            // スタビライザーを再開
            [robot enableStabilization:YES];
        }
        [robot disableSensors];
        [robot removeResponseObserver:self];
    } else {
        // まだセンサーが残ってる
        [self startSensor:streamingMask divisor:kSensorDivisor serviceId:serviceId];
    }
}

// 共通センサー開始処理
- (void)startSensor:(RKDataStreamingMask)mask divisor:(uint16_t)devisor serviceId:(NSString*)serviceId
{
    if (!_isActivated) return;
    
    _prevDate = [NSDate date];
    RKConvenienceRobot *robot = deviceList[serviceId];

    // 一旦止める
    [robot stop];
    if (mask & RKDataStreamingMaskAccelerometerFilteredAll ||
        mask & RKDataStreamingMaskQuaternionAll) {
        // 姿勢センサーとクォータニオンセンサーの場合はスタビライザーを停止
        [robot enableStabilization:NO];
    }
    
    [robot enableSensors:mask atStreamingRate:10];
    [robot addResponseObserver:self];
}

/*
 数値判定。
 */
- (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}

// 整数かどうかを判定する。 true:存在する
- (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:kDPSpheroRegexDigit];
}

// 少数かどうかを判定する。
- (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:kDPSpheroRegexDecimalPoint];
}


@end
