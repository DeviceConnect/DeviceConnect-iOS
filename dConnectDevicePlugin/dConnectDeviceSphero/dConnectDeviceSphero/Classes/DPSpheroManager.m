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
#import <RobotKit/RKGetUserRGBLEDColorCommand.h>
#import <DConnectSDK/DConnectService.h>
#import "DPSpheroService.h"


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
        
        // Sphero接続処理
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSDictionary *device in [self deviceList]) {
                [self connectDeviceWithID:device[@"id"]];
                
            }
        });
    }
    return self;
}

// アプリがバックグラウンドに入った
- (void)applicationDidEnterBackground
{
    [self removeResponseObserver];
    // センサーのマスクを保持
    _streamingMask = [RKSetDataStreamingCommand currentMask];

}

// アプリがフォアグラウンドに入った
- (void)applicationWillEnterForeground
{

    // すぐは復帰できないので。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Sphero接続処理
        for (NSDictionary *device in [self deviceList]) {
            [self connectDeviceWithID:device[@"id"]];
        }

        [self addResponseObserver];
        // センサーを復帰
        [self startSensor:_streamingMask divisor:kSensorDivisor];
        if (_startedCollisionSensor) {
            [self startSensorCollision];
        }
    });
}

// 有効化
- (BOOL)activate
{
    return [[[RKRobotProvider sharedRobotProvider] robots] count] > 0;
}

// 無効化
- (void)deactivate
{
   _isActivated = NO;
}

// 接続中のサービスID取得
- (NSString*)currentServiceID
{
    if (!_isActivated) return nil;
    
    return [[[RKRobotProvider sharedRobotProvider] robot] bluetoothAddress];
}

// デバイスに接続
- (BOOL)connectDeviceWithID:(NSString*)serviceID
{
    if (!_isActivated) return NO;
    
    RKRobotProvider *provider = [RKRobotProvider sharedRobotProvider];
    NSString *oldID = [provider robot].bluetoothAddress;
    // FIXME: これをやると動きがおかしくなる
    // 接続済みチェック
    if ([oldID isEqualToString:serviceID]) {
        [provider openRobotConnection];
        return YES;
    }
    
    // 検索して接続
    [provider closeRobotConnection];
    NSArray *robots = [provider robots];
    for (int i=0; i<[robots count]; i++) {
        RKRobot *robo = robots[i];
        if ([robo.bluetoothAddress isEqualToString:serviceID]
            && [provider controlRobotAtIndex:i]) {
            
            // 現在設定されているLED色を取得
            if (![oldID isEqualToString:serviceID]) {
                [[RKDeviceMessenger sharedMessenger] addResponseObserver:self
                                                                selector:
                                                @selector(handleResponse:)];
                [RKGetUserRGBLEDColorCommand sendCommand];
            }
            // キャリブレーションLEDの明るさをリセット
            // FIXME: キャリブレーションLEDの明るさを取得する命令がないので、
            // LEDを付けたまま接続するとズレが生じる。
            _calibrationLightBright = 0;
            _streamingMask = 0;
            _startedCollisionSensor = NO;
            
            // デバイス管理情報更新
            [self updateManageServices];

            return YES;
        }
    }
    return NO;
}

// 接続可能なデバイスリスト取得
- (NSArray*)deviceList
{
    if (!_isActivated) return nil;
    
    // [[RKRobotProvider sharedRobotProvider] robots]には、
    // 現在接続中のものだけではなく以前に接続したことのあるデバイスも含まれている。
    // 現在オンラインのデバイスは、robo.connection.connectionStateに
    // RKConnectionStateJumpMainAppまたはRKConnectionStateOnlineが設定されるようである。
    // オフラインのデバイスは、RKConnectionStateOfflineが設定されるようである。
    NSMutableArray *array = [NSMutableArray array];
    for (RKRobot *robo in [[RKRobotProvider sharedRobotProvider] robots]) {
        //NSLog(@"%@", robo);
        //NSLog(@"%@", robo.accessory.name);
        //NSLog(@"%@", robo.bluetoothAddress);
        NSString *connectionState = CONNECTION_STATE_OFFLINE;
        if (robo.connection.connectionState != RKConnectionStateOffline) {
            connectionState = CONNECTION_STATE_ONLINE;
        }
        
        [array addObject:@{@"name": robo.accessory.name, @"id": robo.bluetoothAddress, CONNECTION_STATE:connectionState}];
    }
    return array;
}


// デバイス管理情報更新
- (void) updateManageServices {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.serviceProvider) {
            return;
        }
        
        NSArray *deviceList = [self deviceList];
        
        // ServiceProviderに存在するサービスがdeviceListに存在する場合は、deviceのオンライン／オフライン状態を参照して設定する
        // 存在しない場合は、オフラインにする
        for (DConnectService *service in [self.serviceProvider services]) {
            NSString *serviceId = [service serviceId];
            BOOL isFindDevice = NO;
            BOOL isOnline = NO;
            for (NSDictionary *device in deviceList) {
                NSString *deviceServiceId = device[@"id"];
                if (deviceServiceId && [serviceId localizedCaseInsensitiveCompare: deviceServiceId] == NSOrderedSame) {
                    isFindDevice = YES;
                    if ([device[CONNECTION_STATE] isEqualToString: CONNECTION_STATE_ONLINE]) {
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
        for (NSDictionary *device in deviceList) {
            NSString *serviceId = device[@"id"];
            NSString *deviceName = device[@"name"];
            BOOL isOnline = NO;
            if ([device[CONNECTION_STATE] isEqualToString: CONNECTION_STATE_ONLINE]) {
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
        }
    }
}

#pragma mark - Observer

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
- (void)handleDataStreaming:(RKDeviceAsyncData *)asyncData
{
    if (!_isActivated) return;
    
    if ([asyncData isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        // 計測間隔
        int interval = [[NSDate date] timeIntervalSinceDate:_prevDate] * 1000;
        
        // Received sensor data
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];

        // Orientation
        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;
        RKGyroData *sensorGyroData = sensorsData.gyroData;
        if ((accelerometerData || sensorGyroData)
            && [_orientationDelegate respondsToSelector:@selector(spheroManagerStreamingOrientation:accel:interval:)]) {
            DPGyroData gyroData;
            gyroData.x = 0.1 * ((double) sensorGyroData.rotationRate.x);
            gyroData.y = 0.1 * ((double) sensorGyroData.rotationRate.y);
            gyroData.z = 0.1 * ((double) sensorGyroData.rotationRate.z);
            DPPoint3D accel;
            accel.x = accelerometerData.acceleration.x;
            accel.y = accelerometerData.acceleration.y;
            accel.z = accelerometerData.acceleration.z;
            [_orientationDelegate spheroManagerStreamingOrientation:gyroData accel:accel interval:interval];
        }
        // Quaternion
        RKQuaternionData *quaternionData = sensorsData.quaternionData;
        if (quaternionData
            && [_sensorDelegate respondsToSelector:@selector(spheroManagerStreamingQuaternion:interval:)]) {
            DPQuaternion quaternion;
            quaternion.q0 = quaternionData.quaternions.q0;
            quaternion.q1 = quaternionData.quaternions.q1;
            quaternion.q2 = quaternionData.quaternions.q2;
            quaternion.q3 = quaternionData.quaternions.q3;
            [_sensorDelegate spheroManagerStreamingQuaternion:quaternion interval:interval];
            //NSLog(@"qt:%f,%f,%f,%f", qt.q0, qt.q1, qt.q2, qt.q3);
        }
        // Locator
        RKLocatorData *locatorData = sensorsData.locatorData;
        if (locatorData
            && [_sensorDelegate respondsToSelector:@selector(spheroManagerStreamingLocatorPos:velocity:interval:)]) {
            CGPoint pos = CGPointMake(locatorData.position.x, locatorData.position.y);
            CGPoint vel = CGPointMake(locatorData.velocity.x, locatorData.velocity.y);
            [_sensorDelegate spheroManagerStreamingLocatorPos:pos velocity:vel interval:interval];
        }
        
        _prevDate = [NSDate date];
        
    } else if ([asyncData isKindOfClass:[RKCollisionDetectedAsyncData class]]) {
        // Collision
        RKCollisionDetectedAsyncData *collisionData = (RKCollisionDetectedAsyncData *)asyncData;
        if (collisionData
            && [_sensorDelegate respondsToSelector:
                @selector(spheroManagerStreamingCollisionImpactAcceleration:axis:power:speed:time:)]) {
            DPPoint3D accel;
            accel.x = collisionData.impactAcceleration.x;
            accel.y = collisionData.impactAcceleration.y;
            accel.z = collisionData.impactAcceleration.z;
            CGPoint axis = CGPointMake(collisionData.impactAxis.x, collisionData.impactAxis.y);
            CGPoint power = CGPointMake(collisionData.impactPower.x, collisionData.impactPower.y);
            float speed = collisionData.impactSpeed;
            NSTimeInterval time = collisionData.timeStamp;
            [_sensorDelegate spheroManagerStreamingCollisionImpactAcceleration:accel
                                                                          axis:axis
                                                                         power:power
                                                                         speed:speed
                                                                          time:time];
        }
    }
}


#pragma mark - Light

// キャリブレーションライトの点灯
- (void)setCalibrationLightBright:(float)calibrationLightBright
{
    if (!_isActivated) return;
    
    _calibrationLightBright = calibrationLightBright;
    [RKBackLEDOutputCommand sendCommandWithBrightness:_calibrationLightBright];
}

// LEDライトの色変更
- (void)setLEDLightColor:(UIColor*)color
{
    if (!_isActivated) return;
    
    _LEDLightColor = color;
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    [RKRGBLEDOutputCommand sendCommandWithRed:red * alpha
                                        green:green * alpha
                                         blue:blue * alpha
                                  userDefault:YES];
    //NSLog(@"rgb:%f, %f, %f", r, g, b);
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
- (void)move:(float)angle velocity:(float)velocity
{
    if (!_isActivated) return;
    [RKRollCommand sendCommandWithHeading:angle velocity:velocity];
}

// 回転
- (void)rotate:(float)angle
{
    if (!_isActivated) return;
    [RKRollCommand sendCommandWithHeading:angle velocity:0.0];
}

// 停止
- (void)stop
{
    if (!_isActivated) return;
    
    [RKRollCommand sendStop];
    [RKAbortMacroCommand sendCommand];
}


#pragma mark - Sensor

// 姿勢センサー開始
- (void)startSensorOrientation
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll
        | RKDataStreamingMaskIMUAnglesFilteredAll
        | RKDataStreamingMaskGyroXFiltered
        | RKDataStreamingMaskGyroYFiltered
        | RKDataStreamingMaskGyroZFiltered;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor];
}

// 姿勢センサー停止
- (void)stopSensorOrientation
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll
    | RKDataStreamingMaskIMUAnglesFilteredAll
    | RKDataStreamingMaskGyroXFiltered
    | RKDataStreamingMaskGyroYFiltered
    | RKDataStreamingMaskGyroZFiltered;
    [self stopSensor:mask];
}

// クォータニオンセンサー開始
- (void)startSensorQuaternion
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskQuaternionAll;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor];
}

// クォータニオンセンサー停止
- (void)stopSensorQuaternion
{
    if (!_isActivated) return;
    
    [self stopSensor:RKDataStreamingMaskQuaternionAll];
}

// 位置センサー開始
- (void)startSensorLocator
{
    if (!_isActivated) return;
    
    RKDataStreamingMask mask = RKDataStreamingMaskLocatorAll;
    mask = [RKSetDataStreamingCommand currentMask] | mask;
    [self startSensor:mask divisor:kSensorDivisor];
    [RKConfigureLocatorCommand sendCommandForFlag:0 newX:0 newY:0 newYaw:0];
}

// 位置センサー停止
- (void)stopSensorLocator
{
    if (!_isActivated) return;
    
    [self stopSensor:RKDataStreamingMaskLocatorAll];
}

// 衝突センサー開始
- (void)startSensorCollision
{
    if (!_isActivated) return;
    
    _prevDate = [NSDate date];
    _startedCollisionSensor = YES;
    
    int xThreshold = 90;
    int yThreshold = 90;
    int xSpeedThreshold = 130;
    int ySpeedThreshold = 130;
    int deadZone = 1000;
    [RKConfigureCollisionDetectionCommand sendCommandForMethod:RKCollisionDetectionMethod1
                                                    xThreshold:xThreshold
                                               xSpeedThreshold:xSpeedThreshold
                                                    yThreshold:yThreshold
                                               ySpeedThreshold:ySpeedThreshold
                                              postTimeDeadZone:deadZone];
    ////Register for asynchronise data streaming packets
    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleDataStreaming:)];
}

// 衝突センサー停止
- (void)stopSensorCollision
{
    if (!_isActivated) return;
    _startedCollisionSensor = NO;
    
    [RKConfigureCollisionDetectionCommand sendCommandToStopDetection];
    [self stopSensor:0];
}

// 全センサー停止
- (void)stopAllSensor
{
    if (!_isActivated) return;
    
    _startedCollisionSensor = NO;
    
    [RKConfigureCollisionDetectionCommand sendCommandToStopDetection];
    // Turn off data streaming
    [RKSetDataStreamingCommand sendCommandStopStreaming];
    // Unregister for async data packets
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
    // スタビライザーを再開
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
}

// センサー停止
- (void)stopSensor:(RKDataStreamingMask)mask
{
    if (!_isActivated) return;
    
    RKDataStreamingMask streamingMask = mask;
    // 指定のセンサーを外す
    if (streamingMask) {
        //NSLog(@"stopSensor_pre:%llx", mask);
        streamingMask = [RKSetDataStreamingCommand currentMask] & (0xFFFFFFFFFFFFFFFF^mask);
        //NSLog(@"stopSensor_after:%llx", mask);
    }
    
    if (!(streamingMask & RKDataStreamingMaskAccelerometerFilteredAll) &&
        !(streamingMask & RKDataStreamingMaskQuaternionAll)) {
        // 姿勢センサーとクォータニオンセンサーが無い場合はスタビライザーを再開
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    }

    if (streamingMask == RKDataStreamingMaskOff) {
        if (!_startedCollisionSensor) {
            // Turn off data streaming
            [RKSetDataStreamingCommand sendCommandStopStreaming];
            // Unregister for async data packets
            [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
            // スタビライザーを再開
            [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
        }
    } else {
        // まだセンサーが残ってる
        [self startSensor:streamingMask divisor:kSensorDivisor];
    }
}

// 共通センサー開始処理
- (void)startSensor:(RKDataStreamingMask)mask divisor:(uint16_t)devisor
{
    if (!_isActivated) return;
    
    _prevDate = [NSDate date];
    
    // 一旦止める
    [RKSetDataStreamingCommand sendCommandStopStreaming];
    
    if (mask & RKDataStreamingMaskAccelerometerFilteredAll ||
        mask & RKDataStreamingMaskQuaternionAll) {
        // 姿勢センサーとクォータニオンセンサーの場合はスタビライザーを停止
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
    }
    
    // Send command to Sphero
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:kSensorDivisor
                                                   packetFrames:1
                                                     sensorMask:mask
                                                    packetCount:0];
    
    ////Register for asynchronise data streaming packets
    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleDataStreaming:)];
    
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


- (void)addResponseObserver {
    [[RKDeviceMessenger sharedMessenger] addResponseObserver:self
                                                    selector:@selector(handleResponse:)];

}


- (void)removeResponseObserver {
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];

    [[RKDeviceMessenger sharedMessenger] removeResponseObserver:self];

}


@end
