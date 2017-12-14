//
//  DPHostGeolocationProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <CoreLocation/CoreLocation.h>
#import <DConnectSDK/DConnectSDK.h>

#import "DPHostDevicePlugin.h"
#import "DPHostGeolocationProfile.h"
#import "DPHostService.h"
#import "DPHostUtils.h"

// インターバル（ミリ秒）
static const double LocationDeviceIntervalMilliSec = 1000;
// 位置情報有効時間（ミリ秒）
static const long long MaximumAgeMilliSec = 0;

@interface DPHostGeolocationProfile () <CLLocationManagerDelegate>

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

// Location Manager
@property (nonatomic, retain) CLLocationManager  *locationMgr;

/// @brief 位置情報オブジェクトを一時的にキャッシュする変数
@property DConnectMessage *position;

// 位置情報One-shot測位フラグ
@property BOOL oneShot;

// One-shot測位返送先
@property DConnectResponseMessage *resp;

// サービスID
@property NSString *svcId;

// インターバル（ミリ秒）
@property double eventInterval;

// インターバルタイマー
@property NSTimer *timer;

// 最終イベント送信時刻
@property long long lastSendEventTime;


// 位置情報データからpositionデータを作成する.
- (DConnectMessage *) createPositionWithLocation:(CLLocation *)location;

// 位置情報イベントを送信する.
- (void) sendOnWatchPositionEventWithPosition:(CLLocation *)location;

// LocationManagerから位置情報を取得する.
- (void)getLocationData:(NSTimer *)timer;

// イベント登録がされているか確認を行う.
- (BOOL) isEmptyEventList:(NSString *)serviceId;

// 位置情報サービスの有効無効を判定する.
- (BOOL) isLocationServicesEnabled;

// 位置情報のキャッシュ有効無効を判定する.
- (BOOL) checkCacheEnable:(long) maximumAge;

// 測位開始
- (void) startGPS:(BOOL)bAccurary;

// 測位停止
- (void) stopGPS;

@end

@implementation DPHostGeolocationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        self.locationMgr = [CLLocationManager new];
        __weak DPHostGeolocationProfile *weakSelf = self;
        __weak DConnectEventManager *weakEventMgr = self.eventMgr;
        __weak CLLocationManager *weakLocationMgr = self.locationMgr;
        __block NSTimer *blockTimer = self.timer;

        _position = nil;
        _lastSendEventTime = 0;
        _oneShot = NO;
        _svcId = nil;
        
        // API登録(didReceiveGetCurrentPositionRequest相当)
        NSString *getCurrentPositionRequestApiPath = [self apiPath: nil
                                                      attributeName:DConnectGeolocationProfileAttrCurrentPosition];
        [self addGetPath: getCurrentPositionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         Boolean accuracy = [DConnectGeolocationProfile highAccuracyFromRequest: request];
                         long maxAge = 0;
                         NSNumber *maximumAge = [DConnectGeolocationProfile maximumAgeFromRequest: request];
                         if (!maximumAge) {
                             maxAge = MaximumAgeMilliSec;
                         } else {
                             maxAge = [maximumAge longValue];
                         }
                         
                         if ([weakSelf isEmptyEventList:serviceId]) {
                            // 位置情報を取得の許可を得る
                            [weakLocationMgr requestWhenInUseAuthorization];

                             if (![weakSelf isLocationServicesEnabled]) {
                                 [response setErrorToIllegalDeviceStateWithMessage:@"Invalid position information setting."];
                                 return YES;
                             }

                             if ([weakSelf checkCacheEnable: maxAge]) {
                                 [DConnectGeolocationProfile setPosition:weakSelf.position target: response];
                                 [response setResult:DConnectMessageResultTypeOk];
                                 return YES;
                             }
                             _svcId = serviceId;
                             _resp = response;
                             _oneShot = YES;

                             // 測位開始
                             [weakSelf startGPS:accuracy];
                             return NO;
                         } else {
                             if ([weakSelf checkCacheEnable: maxAge]) {
                                 [DConnectGeolocationProfile setPosition:weakSelf.position target: response];
                                 [response setResult:DConnectMessageResultTypeOk];
                                 return YES;
                             }
                             _svcId = serviceId;
                             _resp = response;
                             _oneShot = YES;
                             return NO;
                         }
                     }];
        
        // API登録(didReceivePutOnWatchPositionRequest相当)
        NSString *putOnWatchPositionRequestApiPath = [self apiPath: nil
                                                      attributeName: DConnectGeolocationProfileAttrOnWatchPosition];
        [self addPutPath: putOnWatchPositionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         BOOL accuracy = [DConnectGeolocationProfile highAccuracyFromRequest: request];
                         NSNumber *interval = [DConnectGeolocationProfile intervalFromRequest: request];
                         if (!interval) {
                             weakSelf.eventInterval = LocationDeviceIntervalMilliSec;
                         } else {
                             weakSelf.eventInterval = [interval doubleValue];
                         }
                         
                         if ([weakSelf isEmptyEventList:serviceId]) {
                             // 位置情報を取得の許可を得る
                             [weakLocationMgr requestWhenInUseAuthorization];

                             // 測位開始。
                             [weakSelf startGPS:accuracy];
 
                             // インターバルタイマー設定
                             blockTimer = [NSTimer timerWithTimeInterval:(weakSelf.eventInterval/1000)
                                                                 target:self
                                                               selector:@selector(getLocationData:)
                                                               userInfo:nil
                                                                repeats:YES];
                             [[NSRunLoop mainRunLoop] addTimer:blockTimer forMode:NSRunLoopCommonModes];
                         }
                         
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [weakSelf stopGPS];
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [weakSelf stopGPS];
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnWatchPositionRequest相当)
        NSString *deleteOnWatchPositionRequestApiPath = [self apiPath: nil
                                                            attributeName: DConnectGeolocationProfileAttrOnWatchPosition];
        [self addDeletePath: deleteOnWatchPositionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         switch ([weakEventMgr removeEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         if ([weakSelf isEmptyEventList:serviceId]) {
                             // 位置情報を取得の許可を得る
                             [weakLocationMgr requestWhenInUseAuthorization];
                             [weakSelf stopGPS];
                         }
                         
                         return YES;
                     }];
    } else {
        NSLog(@"HostGeolocationProfile Failure.");
    }
    return self;
}

- (void)dealloc
{
    if (self.locationMgr) {
        [self stopGPS];
    }
}

- (DConnectMessage *) createPositionWithLocation:(CLLocation *)location
{
    DConnectMessage *coordinates = [DConnectMessage message];
    
    [DConnectGeolocationProfile setLatitude:location.coordinate.latitude target:coordinates];
    [DConnectGeolocationProfile setLongitude:location.coordinate.longitude target:coordinates];
    [DConnectGeolocationProfile setAltitude:location.altitude target:coordinates];
    [DConnectGeolocationProfile setAccuracy:location.horizontalAccuracy target:coordinates];
    [DConnectGeolocationProfile setAltitudeAccuracy:location.verticalAccuracy target:coordinates];
    [DConnectGeolocationProfile setHeading:location.course target:coordinates];
    [DConnectGeolocationProfile setSpeed:location.speed target:coordinates];
    
    DConnectMessage *position = [DConnectMessage message];
    [DConnectGeolocationProfile setCoordinates:coordinates target:position];
    [DConnectGeolocationProfile setTimeStamp:([location.timestamp timeIntervalSince1970] * 1000) target:position];
    NSDate *timeDate = location.timestamp;
    NSString *timeStr = [DConnectRFC3339DateUtils stringWithDate:timeDate];
    [DConnectGeolocationProfile setTimeStampString:timeStr target:position];
 
    return position;
}

- (void) sendOnWatchPositionEventWithPosition:(CLLocation *)location
{
    DConnectMessage *position = [self createPositionWithLocation:location];
    _position = position;

    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectGeolocationProfileName
                                          attribute:DConnectGeolocationProfileAttrOnWatchPosition];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectGeolocationProfile setPosition:position target:eventMsg];
        [SELF_PLUGIN sendEvent:eventMsg];
        _lastSendEventTime = [location.timestamp timeIntervalSince1970];
    }
}

- (void)getLocationData:(NSTimer *)timer {
    CLLocation *location = [_locationMgr location];
    [self sendOnWatchPositionEventWithPosition: location];
}

- (BOOL) isEmptyEventList:(NSString *)serviceId {
    NSArray *evts = [_eventMgr eventListForServiceId:serviceId
                                             profile:DConnectGeolocationProfileName
                                           attribute:DConnectGeolocationProfileAttrOnWatchPosition];
    return evts == nil || [evts count] == 0;
}

- (BOOL) isLocationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (BOOL) checkCacheEnable:(long) maximumAge
{
    if (_lastSendEventTime == 0) {
        return false;
    }
    NSDate* now = [NSDate date];
    long long nowTime = (long long)([now timeIntervalSince1970] * 1000);
    if (nowTime - _lastSendEventTime < maximumAge) {
        return true;
    } else {
        return false;
    }
}

- (void) startGPS:(BOOL)accurary
{
    if (accurary) {
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    } else {
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    self.locationMgr.distanceFilter = kCLDistanceFilterNone;
    self.locationMgr.delegate = self;
    
    [self.locationMgr startUpdatingLocation];
}

- (void) stopGPS
{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    [self.locationMgr stopUpdatingLocation];
}

#pragma mark CLLocationManagerDelegete method.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (_oneShot) {
        _oneShot = false;
        CLLocation *location = [locations lastObject];
        DConnectMessage *position = [self createPositionWithLocation:location];
        [DConnectGeolocationProfile setPosition:position target: _resp];
        [_resp setResult:DConnectMessageResultTypeOk];
        DConnectManager *mgr = [DConnectManager sharedManager];
        [mgr sendResponse: _resp];
        
        if ([self isEmptyEventList:_svcId]) {
            [self stopGPS];
            _position = position;
            _lastSendEventTime = (long long)[location.timestamp timeIntervalSince1970] * 1000;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error) {
        NSString *message = nil;

        switch ([error code]) {
            case kCLErrorDenied:
                [self stopGPS];
                message = [NSString stringWithFormat:@"Location information service is not permitted."];
                break;
            default:
                message = [NSString stringWithFormat:@"Failed to acquire location information."];
                break;
        }
        if (message) {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            UIAlertAction* okButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        }];
            
            [alert addAction:okButton];
            UIViewController *top = [DPHostUtils topViewController];
            [top presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end
