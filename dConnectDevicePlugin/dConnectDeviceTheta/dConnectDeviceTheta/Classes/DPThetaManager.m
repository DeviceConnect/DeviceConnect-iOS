//
//  DPThetaManager.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaManager.h"
#import "DPThetaDevicePlugin.h"
#import "PtpConnection.h"
#import "PtpLogging.h"
#import "DPThetaService.h"
#import "DPThetaReachability.h"

static NSString * const DPThetaRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.*)?([0-9]*)?$";
static NSString * const DPThetaRegexDigit = @"^([0-9]*)?$";
static NSString * const DPThetaRegexCSV = @"^([^,]*,)+";

static NSString * const ROI_IMAGE_SERVICE = @"ROI Image Service";


@interface DPThetaManager()<PtpIpEventListener>
{
    PtpConnection* _ptpConnection;
    NSMutableArray* _objects;
    PtpIpStorageInfo* _storageInfo;
    NSString* _deviceInfo;
    NSUInteger _batteryLevel;
    NSUInteger _cameraStatus;
    DPThetaBlock _imageCallback;
    NSMutableDictionary* _onPhotoEventList;
    NSMutableDictionary* _onStatusEventList;
    CGSize _imageSize;
    BOOL _isUpdateManageServicesRunning;
    NSInteger _transactionId;
    PtpIpSession *_session;
}

@property (nonatomic, strong) DPThetaReachability *reachability;

@end

@implementation DPThetaManager

/*!
 セマフォのタイムアウト時間[秒]
 */
static int const _timeout = 120;

/**
 動画停止状態
 */
static int const DPThetaManagerInactive = 0xFFFFFFFF;

// share instance
+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceSpheroToken;
    dispatch_once(&onceSpheroToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// init
- (instancetype)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
        _imageCallback = nil;
        _cameraStatus = 0;
        _deviceInfo = nil;
        _batteryLevel = 0;
        _onPhotoEventList = [NSMutableDictionary new];
        _onStatusEventList = [NSMutableDictionary new];
        _isUpdateManageServicesRunning = NO;
        _transactionId = DPThetaManagerInactive;
        // Ready to PTP/IP.
        _ptpConnection = [PtpConnection new];
        [_ptpConnection setLoglevel:PTPIP_LOGLEVEL_ERROR];
        [_ptpConnection setEventListener:self];


        _session =nil;
        
        // Reachabilityの初期処理
        self.reachability = [DPThetaReachability reachabilityWithHostName: @"www.google.com"];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(notifiedNetworkStatus:)
         name:DPThetaReachabilityChangedNotification
         object:nil];
        [self.reachability startNotifier];
    }
    return self;
}

#pragma mark - PtpIpEventListener delegates.

-(void)ptpip_eventReceived:(int)code :(uint32_t)param1 :(uint32_t)param2 :(uint32_t)param3
{
   // PTP/IP-Event callback.
    if (code == PTPIP_OBJECT_ADDED) {
        if (!_session) {
            _session = [self session];
        }
        [_ptpConnection operateSession:^(PtpIpSession *session) {
            PtpIpObjectInfo *objectInfo = [self loadObject:param1 session:session];
            if (objectInfo.object_format == PTPIP_FORMAT_JPEG) {
                NSString *filePath = [self saveImageFileWithPtpIpObjectInfo:objectInfo
                                                                    session:session];
                if (_imageCallback) {
                    _imageCallback(filePath, objectInfo.filename);
                    _imageCallback = nil;
                }
                //OnPhotoのコールバック
                for (id key in [_onPhotoEventList keyEnumerator]) {
                    DPThetaOnPhotoBlock callback = _onPhotoEventList[key];
                    if (callback) {
                        callback(filePath);
                    }
                }
            }

        }];
    } else {
        for (id key in [_onStatusEventList keyEnumerator]) {
            DPThetaOnStatusChangeCallback callback = _onStatusEventList[key];
            if (callback) {
                callback(@"recording", nil);
            }
        }
    }
}

-(void)ptpip_socketError:(int)err
{
    // socket error callback.
    // This method is running at PtpConnection#gcd thread.
    
    // If libptpip closed the socket, `closed` is non-zero.
    BOOL closed = PTP_CONNECTION_CLOSED(err);
    int error = err;
    // PTPIP_PROTOCOL_*** or POSIX error number (errno()).
    error = PTP_ORIGINAL_PTPIPERROR(err);
    
    NSArray* errTexts = @[@"Socket closed",              // PTPIP_PROTOCOL_SOCKET_CLOSED
                          @"Brocken packet",             // PTPIP_PROTOCOL_BROCKEN_PACKET
                          @"Rejected",                   // PTPIP_PROTOCOL_REJECTED
                          @"Invalid session id",         // PTPIP_PROTOCOL_INVALID_SESSION_ID
                          @"Invalid transaction id.",    // PTPIP_PROTOCOL_INVALID_TRANSACTION_ID
                          @"Unrecognided command",       // PTPIP_PROTOCOL_UNRECOGNIZED_COMMAND
                          @"Invalid receive state",      // PTPIP_PROTOCOL_INVALID_RECEIVE_STATE
                          @"Invalid data length",        // PTPIP_PROTOCOL_INVALID_DATA_LENGTH
                          @"Watchdog expired",           // PTPIP_PROTOCOL_WATCHDOG_EXPIRED
                          ];
    NSString* desc = @(strerror(error));
    if ((PTPIP_PROTOCOL_SOCKET_CLOSED<=error) && (err<=PTPIP_PROTOCOL_WATCHDOG_EXPIRED)) {
        desc = errTexts[error - PTPIP_PROTOCOL_SOCKET_CLOSED];
    }
    if (closed) {
        [_objects removeAllObjects];
    }
    for (id key in [_onStatusEventList keyEnumerator]) {
        DPThetaOnStatusChangeCallback callback = _onStatusEventList[key];
        if (callback) {
            callback(@"error", desc);
        }
    }
    if (_imageCallback) {
        _imageCallback(nil, nil);
        _imageCallback = nil;
    }

}

// Sessionオブジェクトを取得する
- (PtpIpSession*)session {
    __block PtpIpSession* sess = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * _timeout);
    [_ptpConnection operateSession:^(PtpIpSession *session)
     {
         sess = session;
         dispatch_semaphore_signal(semaphore);
     }];
    dispatch_semaphore_wait(semaphore, timeout);
    return sess;
}

// 接続
- (BOOL)connect
{
    if (!_ptpConnection) {
        _ptpConnection = [PtpConnection new];
        [_ptpConnection setLoglevel:PTPIP_LOGLEVEL_ERROR];
        [_ptpConnection setEventListener:self];
    }
    if ([_ptpConnection connected]) {
        [self updateManageServices: YES];
        return YES;
    }
    __block BOOL result = NO;
    // Setup `target IP`(camera IP).
    // Product default is "192.168.1.1".
    [_ptpConnection setTargetIp:@"192.168.1.1"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * _timeout);

    
    [_ptpConnection connect:^(BOOL connected) {
        result = connected;
        dispatch_semaphore_signal(semaphore);

    }];

    dispatch_semaphore_wait(semaphore, timeout);
    
    [self setImageSize:CGSizeMake(2048,1024)];
    [self updateManageServices: YES];
    return result;

}

// 接続断
- (void)disconnect
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * _timeout);

    [_ptpConnection close:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, timeout);
    _session = nil;
    _ptpConnection = nil;
    [self updateManageServices: NO];
}

// 初期値の更新
- (void)enumObjects
{
    [_objects removeAllObjects];
    
    [_ptpConnection getDeviceInfo:^(const PtpIpDeviceInfo* info) {
        // "GetDeviceInfo" completion callback.
        _deviceInfo = info.serial_number;
    }];
    
    if (!_session) {
        _session = [self session];
    }
    [_session setDateTime:[NSDate dateWithTimeIntervalSinceNow:0]];
    _storageInfo = [_session getStorageInfo];
    _batteryLevel = [_session getBatteryLevel];
    
    NSArray* objectHandles = [_session getObjectHandles];
    
    for (NSNumber* it in objectHandles) {
        uint32_t objectHandle = (uint32_t)it.integerValue;
        PtpIpObjectInfo *obj = [self loadObject:objectHandle session:_session];
        if (obj) {
            [_objects addObject:obj];
        }
    }
}

- (PtpIpObjectInfo*)loadObject:(uint32_t)objectHandle session:(PtpIpSession*)session
{
    PtpIpObjectInfo* objectInfo = [session getObjectInfo:objectHandle];
    if (!objectInfo) {
        return nil;
    }
    
    return objectInfo;
}



// Thetaと接続されているかどうか
- (BOOL)isConnected {
    return [_ptpConnection connected];
}


// take a photo in the Theta
- (BOOL)takePictureWithCompletion:(void(^)(NSString *uri, NSString* path))completion
                          fileMgr:(DConnectFileManager*)fileMgr
{
    self.fileMgr = fileMgr;
    BOOL result = NO;
    if (!_session) {
        _session = [self session];
    }

    if (_imageCallback) {
        return NO;
    }
     // Single shot mode or Interval shooting mode.
     if ([_session getStillCaptureMode] == 1
         || [_session getStillCaptureMode] == 3) {
         result = YES;
         _imageCallback = completion;
         [_session initiateCapture];
     } else {
         result = NO;
     }
    return result;
}

// 動画を撮影する
- (BOOL)recordingMovie {
    BOOL result = NO;
    if (!_session) {
        _session = [self session];
    }
    if (_transactionId != DPThetaManagerInactive) {
        return result;
    }
    // Single shot mode or Interval shooting mode.
     if ([_session getStillCaptureMode] == 0) {
         result = YES;
         [_session setAudioVolume: 1];
         _transactionId = [_session initiateOpenCapture];
     } else {
         result = NO;
     }
    return result;
}

// 動画を撮影を停止する
- (BOOL)stopMovie {
    BOOL result = NO;
    if (!_session) {
        _session = [self session];
    }
    // Single shot mode or Interval shooting mode.
     if ([_session getStillCaptureMode] == 0) {
         //OnStatusChangeのコールバック
         for (id key in [_onStatusEventList keyEnumerator]) {
             DPThetaOnStatusChangeCallback callback = _onStatusEventList[key];
             if (callback) {
                 callback(@"stop", nil);
             }
             [_onStatusEventList removeObjectForKey:key];
             // デバイス管理情報更新
             [self updateManageServices: YES];
         }
         result = [_session terminateOpenCapture: _transactionId];
         _transactionId = DPThetaManagerInactive;
         [self disconnect];
     } else {
         result = NO;
     }
    return result;
}

// BatteryのLevelを返す
- (NSUInteger)getBatteryLevel {
    _session = [self session];
    return [_session getBatteryLevel];
}

//シリアルNoを返す
- (NSString*)getSerialNo {
    _deviceInfo = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * _timeout);

    [_ptpConnection getDeviceInfo:^(const PtpIpDeviceInfo* info) {
        if (info && info.model && info.serial_number) {
            _deviceInfo = [NSString stringWithFormat:@"%@ %@", info.model, info.serial_number];
        } else {
            _deviceInfo = nil;
        }
    
        dispatch_semaphore_signal(semaphore);

    }];
    dispatch_semaphore_wait(semaphore, timeout);

    return _deviceInfo;
}

//カメラのステータスを返す
- (NSUInteger)getCameraStatus {
    __block NSUInteger status = 0;
    _session = [self session];
    // Single shot mode or Interval shooting mode.
     status = [_session getStillCaptureMode];
    return status;
}


#pragma mark- Set Event

- (void)addOnPhotoEventCallbackWithID:(NSString*)serviceId
                              fileMgr:(DConnectFileManager*)fileMgr
                             callback:(void (^)(NSString *path))callback
{
    self.fileMgr = fileMgr;
    _onPhotoEventList[serviceId] = callback;
}

- (void)addOnStatusEventCallbackWithID:(NSString*)serviceId
                              callback:(void (^)(NSString *status, NSString *message))callback
{
    _onStatusEventList[serviceId] = callback;
}

- (void)removeOnPhotoEventCallbackWithID:(NSString*)serviceId
{
    [_onPhotoEventList removeObjectForKey:serviceId];
}

- (void)removeOnStatusEventCallbackWithID:(NSString*)serviceId
{
    [_onStatusEventList removeObjectForKey:serviceId];
}


- (NSString*)saveImageFileWithPtpIpObjectInfo:(PtpIpObjectInfo *)ptpIp
                                      session:(PtpIpSession *)session
{
    NSString *path = ptpIp.filename;
    if (!self.fileMgr) {
        return nil;
    }

    NSString *dstPath = [self pathByAppendingPathComponent:path];
    NSData *data = [self getDataWithPtpObject:ptpIp
                    session:session];
    NSString *resultPath = [self.fileMgr createFileForPath:dstPath contents:data];
    return resultPath;
}



//バイナリーデータを取得する
-(NSData*)getDataWithPtpObject:(PtpIpObjectInfo *)ptpInfo
                    session:(PtpIpSession *)session
{
    NSMutableData* imageData = [NSMutableData data];
    uint32_t objectHandle = (uint32_t)ptpInfo.object_handle;
    [session getResizedImageObject:objectHandle
                             width:2048
                            height:1024
                       onStartData:^(NSUInteger totalLength) {
                       } onChunkReceived:^BOOL(NSData *data) {
                           // Callback for each chunks.
                           [imageData appendData:data];
                           return YES;
                       }];
    return (NSData*) imageData;

}


// ファイルを削除する
- (BOOL)removeFileWithName:(NSString*)fileName
                   fileMgr:(DConnectFileManager*)fileMgr

{
    self.fileMgr = fileMgr;
    __block BOOL isSuccess = NO;
    if (!_session) {
        _session = [self session];
    }
    NSArray* objectHandles = [_session getObjectHandles];
        
    for (NSNumber* it in objectHandles) {
        uint32_t objectHandle = (uint32_t)it.integerValue;
        PtpIpObjectInfo *obj = [self loadObject:objectHandle session:_session];
        if ([fileName isEqualToString:obj.filename]) {
            [_session deleteObject: objectHandle];
            isSuccess = YES;
        }
    }
    return isSuccess;
}


- (NSString*)receiveImageFileWithFileName:(NSString *)fileName
                                  fileMgr:(DConnectFileManager*)fileMgr
{
    self.fileMgr = fileMgr;
    PtpIpObjectInfo *ptpInfo;
    NSString *path = nil;
    if (!_session) {
        _session = [self session];
    }
    NSArray* objectHandles = [_session getObjectHandles];
    
    for (NSNumber* it in objectHandles) {
        uint32_t objectHandle = (uint32_t)it.integerValue;
        PtpIpObjectInfo *obj = [self loadObject:objectHandle session:_session];
        if ([fileName isEqualToString:obj.filename]) {
            ptpInfo = obj;
            path = [self saveImageFileWithPtpIpObjectInfo:ptpInfo
                              session:_session];
        }
    }
    return path;
}



// ファイルを取得する
- (NSMutableArray*)getAllFiles
{
    NSMutableArray *images = [NSMutableArray array];
    if (!_session) {
        _session = [self session];
    }
    NSArray* objectHandles = [_session getObjectHandles];
        
    for (NSNumber* it in objectHandles) {
        uint32_t objectHandle = (uint32_t)it.integerValue;
        PtpIpObjectInfo *obj = [self loadObject:objectHandle session:_session];
        if (obj.object_format == PTPIP_FORMAT_JPEG) {
            [images addObject:obj];
        }
    }
    return images;
}



// イメージのサイズを指定する
- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
}

// アプリがバックグラウンドに入った
- (void)applicationDidEnterBackground
{
    if (_ptpConnection) {
        [self disconnect];
    }
}

// アプリがフォアグラウンドに入った
- (void)applicationWillEnterForeground
{
    if (_ptpConnection) {
        [self connect];
    }
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        [self updateManageServices: YES];
    });

}

- (NSString *) pathByAppendingPathComponent:(NSString *)pathComponent
{
    return [self.fileMgr.URL URLByAppendingPathComponent:pathComponent].standardizedURL.path;
}


- (NSString *) percentEncodeString:(NSString *)string withEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet *allowedCharSet
    = [[NSCharacterSet characterSetWithCharactersInString:@";/?:@&=$+{}<>., "] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharSet];
}


/*
 数値判定。
 */
+ (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}

// 整数かどうかを判定する。 true:存在する
+ (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:DPThetaRegexDigit];
}

// 少数かどうかを判定する。
+ (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:DPThetaRegexDecimalPoint];
}


+ (BOOL)existBOOL:(NSString*)isBool {
    return [isBool isEqualToString:@"true"] || [isBool isEqualToString:@"false"];
}

+ (NSString*)omitParametersToUri:(NSString*)uri
{
    NSRange range = [uri rangeOfString:@"?"];
    NSUInteger index = range.location;
    if (index != NSNotFound) {
        NSString *param = [uri substringToIndex:index];
        return param;
    }
    return uri;
}

+ (NSString*)omitParametersFromUri:(NSString*)uri
{
    NSRange range = [uri rangeOfString:@"?"];
    NSUInteger index = range.location;
    if (index != NSNotFound) {
        NSString *param = [uri substringFromIndex:index + 1];
        return param;
    }
    return uri;
}

// デバイス管理情報更新
- (void) updateManageServices: (BOOL) onlineForSet {
    // ROI接続中(常時)
    // サービス未登録なら登録する
    if (![self.serviceProvider service: DPThetaRoiServiceId]) {
        DPThetaService *service = [[DPThetaService alloc] initWithServiceId: DPThetaRoiServiceId plugin: self.plugin];
        [service setName: ROI_IMAGE_SERVICE];
        [self.serviceProvider addService: service bundle: DPThetaBundle()];
        [service setOnline:YES];
    }
    // 実行中に呼び出されたらなにもしないで終了
    if (_isUpdateManageServicesRunning) {
        return;
    }
    
    // 実行中フラグを立てる
    _isUpdateManageServicesRunning = YES;
    
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.serviceProvider) {
            _isUpdateManageServicesRunning = NO;
            return;
        }
        
        // オフラインにする場合は、ROIを除く全サービスをオフラインにする
        if (!onlineForSet) {
            for (DConnectService *service in [self.serviceProvider services]) {
                if ([[service name] isEqualToString: ROI_IMAGE_SERVICE]) {
                    continue;
                }
                [service setOnline: NO];
            }
            _isUpdateManageServicesRunning = NO;
            return;
        }
        
        // 接続を試みる(接続成功したらシリアル番号も取得できる)
        BOOL isConnected = [self connect];
        NSString* serial = [self getSerialNo];
        // 接続できた
        if (isConnected && serial) {
            
            // サービス未登録なら登録する
            if (![self.serviceProvider service: DPThetaDeviceServiceId]) {
                DPThetaService *service = [[DPThetaService alloc] initWithServiceId: DPThetaDeviceServiceId plugin: self.plugin];
                [service setName:serial];
                [service setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
                [self.serviceProvider addService: service bundle: DPThetaBundle()];
                [service setOnline:YES];
            } else {
                // サービス登録済ならオンラインにする
                DConnectService *service = [self.serviceProvider service: DPThetaDeviceServiceId];
                [service setOnline:YES];
            }
        } else {
            // 切断中でサービスが登録済ならオフラインにする
            DConnectService *service = [self.serviceProvider service: DPThetaDeviceServiceId];
            if (service) {
                [service setOnline:NO];
            }
        }


        
        _isUpdateManageServicesRunning = NO;
    }
}

// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    // Thetaオンライン判定(Theta接続中はインターネット接続できないのでこの条件で判定する。
    BOOL online = NO;
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        online = YES;
    } else {
        online = NO;
    }
    
    // デバイス管理情報更新
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        [self updateManageServices: online];
    });
}
@end
