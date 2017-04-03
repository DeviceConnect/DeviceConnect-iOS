//
//  SonyCameraManager.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraManager.h"
#import "DeviceList.h"
#import "RemoteApiList.h"
#import <DConnectSDK/DConnectService.h>
#import "SonyCameraService.h"
#import "SonyCameraReachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreFoundation/CoreFoundation.h>
#import "SonyCameraPreview.h"

/*!
 @brief ファイルのプレフィックス。
 */
#define SonyFilePrefix @"sony"

/*!
 @brief サービスIDを保存するキー名.
 */
#define SONY_CAMERA_ID @"sony_came_id"

/*!
 @brief サービス名を保存するキー名.
 */
#define SONY_CAMERA_NAME @"sony_came_name"

@interface SonyCameraDevice : NSObject

@property (nonatomic) NSString *serviceId;
@property (nonatomic) NSString *deviceName;

@end

@implementation SonyCameraDevice

- (id) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.serviceId = [coder decodeObjectForKey:SONY_CAMERA_ID];
        self.deviceName = [coder decodeObjectForKey:SONY_CAMERA_NAME];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.serviceId forKey:SONY_CAMERA_ID];
    [coder encodeObject:self.deviceName forKey:SONY_CAMERA_NAME];
}

@end



@interface SonyCameraManager() <SampleDiscoveryDelegate, SonyCameraRemoteApiUtilDelegate>

@property (nonatomic, strong) SonyCameraReachability *reachability;
@property (nonatomic, strong) SonyCameraPreview *sonyCameraPreview;

@end

@implementation SonyCameraManager

// init
- (instancetype)initWithPlugin:(SonyCameraDevicePlugin *) plugin
{
    self = [super init];
    if (self) {
        self.remoteApi = nil;
        self.searchFlag = NO;
        self.mFileManager = [DConnectFileManager fileManagerForPlugin:plugin];
        self.plugin = plugin;
        self.sonyCameraServices = [NSMutableArray array];
        self.sonyCameraPreview = nil;

        [self loadSonyCameraDevices];

        // Reachabilityの初期処理
        self.reachability = [SonyCameraReachability reachabilityWithHostName: @"www.google.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifiedNetworkStatus:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    // Reachabilityの終了処理
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (BOOL) checkSSID {
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    if (!interfaces) return NO;
    if (CFArrayGetCount(interfaces)==0) return NO;
    CFDictionaryRef dicRef = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
    if (dicRef) {
        NSString *ssid = CFDictionaryGetValue(dicRef, kCNNetworkInfoKeySSID);
        if ([ssid hasPrefix:@"DIRECT-"]) {
            NSArray *array = @[@"HDR-AS100", @"ILCE-6000", @"DSC-HC60V", @"DSC-HX400",
                               @"ILCE-5000", @"DSC-QX10", @"DSC-QX100", @"HDR-AS15",
                               @"HDR-AS30", @"HDR-MV1", @"NEX-5R", @"NEX-5T", @"NEX-6",
                               @"ILCE-7R/B", @"ILCE-7/B"];
            for (NSString *name in array) {
                NSRange searchResult = [ssid rangeOfString:name];
                if (searchResult.location != NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSString *)getCurrentWifiName {
    NSString *wifiName = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    return wifiName;
}

- (void) removeSonyCamera:(SonyCameraService *)service
{
    [self.sonyCameraServices removeObject:service];
    [self saveSonyCameraDevices];
}

- (void) connectSonyCamera {
    if (self.searchFlag) {
        return;
    }
    self.searchFlag = YES;

    [self disconnectSonyCamera];
    
    SampleDeviceDiscovery* discovery = [SampleDeviceDiscovery new];
    [discovery performSelectorInBackground:@selector(discover:) withObject:self];
}

- (void) disconnectSonyCamera {
    [self setOnlineStatus];

    if (self.remoteApi) {
        [self.remoteApi destroy];
        self.remoteApi = nil;
    }

    [DeviceList reset];
}

- (BOOL) isConnectedService:(NSString *)serviceId {
    NSString *ssid = [self getCurrentWifiName];
    return self.remoteApi && ssid && [ssid isEqualToString:serviceId];
}

- (BOOL) isRecording {
    return [SonyCameraStatusMovieRecording isEqualToString:self.remoteApi.cameraStatus];
}

- (BOOL) isPreview {
    return self.sonyCameraPreview && [self.sonyCameraPreview isRunning];
}

- (BOOL) isSupportedZoom {
    return [self.remoteApi isApiAvailable:API_actZoom];
}

- (BOOL) isSupportedPicture {
    return [self.remoteApi isApiAvailable:API_actTakePicture];
}

- (BOOL) isSupportedRecording {
    return [self.remoteApi isApiAvailable:API_stopRecMode];
}

- (void) getCameraState:(SonyCameraStateBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cameraStatus = weakSelf.remoteApi.cameraStatus;
        NSString *status = nil;
        int width = 0;
        int height = 0;
        
        if ([cameraStatus isEqualToString:@"Error"] ||
            [cameraStatus isEqualToString:@"NotReady"] ||
            [cameraStatus isEqualToString:@"MovieSaving"] ||
            [cameraStatus isEqualToString:@"AudioSaving"] ||
            [cameraStatus isEqualToString:@"StillSaving"]) {
            status = DConnectMediaStreamRecordingProfileRecorderStateInactive;
        } else if ([cameraStatus isEqualToString:@"StillCapturing"] ||
                   [cameraStatus isEqualToString:@"MediaRecording"] ||
                   [cameraStatus isEqualToString:@"AudioRecording"] ||
                   [cameraStatus isEqualToString:@"IntervalRecording"]) {
            status = DConnectMediaStreamRecordingProfileRecorderStateRecording;
        } else if ([cameraStatus isEqualToString:@"MovieWaitRecStart"] ||
                   [cameraStatus isEqualToString:@"MoviewWaitRecStop"] ||
                   [cameraStatus isEqualToString:@"AudioWaitRecStart"] ||
                   [cameraStatus isEqualToString:@"AudioRecWaitRecStop"] ||
                   [cameraStatus isEqualToString:@"IntervalWaitRecStart"] ||
                   [cameraStatus isEqualToString:@"IntervalWaitRecStop"]) {
            status = DConnectMediaStreamRecordingProfileRecorderStatePaused;
        } else {
            status = DConnectMediaStreamRecordingProfileRecorderStateUnknown;
        }
        
        NSDictionary *dic = [weakSelf.remoteApi getStillSize];
        if (dic) {
            NSString *aspect = dic[@"aspect"];
            NSString *size = dic[@"size"];
            
            NSArray *sizes = [aspect componentsSeparatedByString:@":"];
            NSString *widthString = sizes[0];
            NSString *heightString = sizes[1];
            int stillSize = 0;
            
            width = [widthString intValue];
            height = [heightString intValue];
            
            if ([aspect isEqualToString:@"1:1"]) {
                if ([size isEqualToString:@"3.7M"]) {
                    stillSize = (1920 * 1920) / (width * height);
                } else if ([size isEqualToString:@"13M"]) {
                    stillSize = (3648 * 3648) / (width * height);
                }
            } else if ([aspect isEqualToString:@"3:2"]) {
                if ([size isEqualToString:@"20M"]) {
                    stillSize = (5472 * 3648) / (width * height);
                } else if ([size isEqualToString:@"5M"]) {
                    stillSize = (2736 * 1824) / (width * height);
                }
            } else if ([aspect isEqualToString:@"4:3"]) {
                if ([size isEqualToString:@"18M"]) {
                    stillSize = (4864 * 3648) / (width * height);
                } else if ([size isEqualToString:@"5M"]) {
                    stillSize = (2592 * 1944) / (width * height);
                }
            } else if ([aspect isEqualToString:@"16:9"]) {
                if ([size isEqualToString:@"17M"]) {
                    stillSize = (5472 * 3080) / (width * height);
                } else if ([size isEqualToString:@"4.2M"]) {
                    stillSize = (2720 * 1528) / (width * height);
                }
            }
            
            if (stillSize == 0) {
                width = 0;
                height = 0;
            } else {
                width = width * stillSize;
                height = height * stillSize;
            }
        }
        
        block(status, width, height);
    });
}


- (void) takePicture:(SonyCameraTakePictureBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 写真モードではない場合には、モードを切り替え
        if (![SonyCameraShootModePicture isEqualToString:weakSelf.remoteApi.shootMode]) {
            if (![self.remoteApi actSetShootMode:SonyCameraShootModePicture]) {
                block(nil);
                return;
            }
        }
        
        NSDictionary *dict = [weakSelf.remoteApi actTakePicture];
        if (dict == nil) {
            block(nil);
        } else {
            NSString *errorMessage = @"";
            NSInteger errorCode = -1;
            NSArray *resultArray = dict[@"result"];
            NSArray *errorArray = dict[@"error"];
            if (errorArray && errorArray.count > 0) {
                errorCode = (NSInteger) errorArray[0];
                errorMessage = errorArray[1];
            }
            
            if (resultArray.count <= 0 && errorCode >= 0) {
                block(nil);
            } else {
                NSArray *arr = resultArray[0];
                NSString *postImageUrl = arr[0];
                if (postImageUrl) {
                    block([weakSelf saveFileFromURL:postImageUrl]);
                } else {
                    block(nil);
                }
            }
        }
    });
}

- (void) startPreviewWithTimeSlice:(NSNumber *)timeSlice block:(SonyCameraPreviewBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakSelf.sonyCameraPreview) {
            [weakSelf.sonyCameraPreview stopPreview];
            weakSelf.sonyCameraPreview = nil;
        }
        
        weakSelf.sonyCameraPreview = [[SonyCameraPreview alloc] initWithRemoteApi:weakSelf.remoteApi];
        BOOL result = [weakSelf.sonyCameraPreview startPreviewWithTimeSlice:timeSlice];
        if (result) {
            block([weakSelf.sonyCameraPreview getUrl]);
        } else {
            block(nil);
        }
    });
}

- (void) stopPreview {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakSelf.sonyCameraPreview) {
            [weakSelf.sonyCameraPreview stopPreview];
            weakSelf.sonyCameraPreview = nil;
        }
    });
}

- (void) startMovieRec:(SonyCameraBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 動画撮影モードではない場合には、モードを切り替え
        if (![SonyCameraShootModeMovie isEqualToString:weakSelf.remoteApi.shootMode]) {
            if (![weakSelf.remoteApi actSetShootMode:SonyCameraShootModeMovie]) {
                block(0, nil);
                return;
            }
        }

        NSDictionary *dict = [weakSelf.remoteApi startMovieRec];
        if (dict) {
            block(0, nil);
        } else {
            block(1, @"error");
        }
    });
}

- (void) stopMovieRec:(SonyCameraBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dict = [weakSelf.remoteApi stopMovieRec];
        if (dict) {
            block(0, nil);
        } else {
            block(1, @"error");
        }
    });
}

- (void) setZoomByDirection:(NSString *)direction
                   movement:(NSString *)movement
                      block:(SonyCameraBlock)block {
    __block typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tmpMovement = movement;
        if ([movement isEqualToString:@"max"]) {
            tmpMovement = @"start";
        }
        
        NSDictionary *dict = [weakSelf.remoteApi actZoom:direction movement:tmpMovement];
        if (dict == nil) {
            block(1, @"timeout");
        } else {
            NSString *errorMessage = @"";
            NSInteger errorCode = -1;
            NSArray *resultArray = dict[@"result"];
            NSArray *errorArray = dict[@"error"];
            if (errorArray && errorArray.count > 0) {
                errorCode = (NSInteger) errorArray[0];
                errorMessage = errorArray[1];
            }
            
            if (resultArray.count <= 0 && errorCode >= 0) {
                block(1, errorMessage);
            } else {
                block(0, nil);
            }
        }
    });
}

- (double) getZoom {
    return self.remoteApi.zoomPosition;
}


#pragma mark - Private Methods

- (void) setShootMode:(NSString *)mode block:(SonyCameraBlock)block {
    if ([self.remoteApi actSetShootMode:mode]) {
        block(0, nil);
    } else {
        block(1, @"error");
    }
}

- (void) setOnlineStatus {
    __block NSString *ssid = [self getCurrentWifiName];
    
    [self.sonyCameraServices enumerateObjectsUsingBlock:^(SonyCameraService *obj, NSUInteger idx, BOOL *stop) {
        if (ssid) {
            [obj setOnline:[obj.serviceId isEqualToString:ssid]];
        } else {
            [obj setOnline:NO];
        }
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveWiFiStatus)]) {
        [self.delegate didReceiveWiFiStatus];
    }
}

- (SonyCameraService *) foundSonyCamera {
    __block NSString *ssid = [self getCurrentWifiName];
    __block SonyCameraService *result = nil;
    
    if (!ssid) {
        return nil;
    }
    
    [self.sonyCameraServices enumerateObjectsUsingBlock:^(SonyCameraService *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.serviceId isEqualToString:ssid]) {
            result = obj;
            *stop = YES;
        }
    }];

    // リストにSonyCameraが存在しない場合
    if (!result) {
        result = [[SonyCameraService alloc] initWithServiceId:ssid
                                                   deviceName:ssid
                                                       plugin:self.plugin];
        [self.sonyCameraServices addObject:result];
        [self.delegate didAddedService:result];
        [self saveSonyCameraDevices];
    }
    
    return result;
}

- (NSData *) download:(NSString *)requestURL {
    NSURL *downoadUrl = [NSURL URLWithString:requestURL];
    NSData *urlData = [NSData dataWithContentsOfURL:downoadUrl];
    return urlData;
}

- (NSString *) saveFile:(NSData *)data
{
    if (!data) {
        return nil;
    }

    // ファイル名作成
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", SonyFilePrefix, dateStr];
    // ファイルを保存
    return [self.mFileManager createFileForPath:fileName contents:data];
}

- (NSString *) saveFileFromURL:(NSString *)requestURL {
    return [self saveFile:[self download:requestURL]];
}

- (void) saveSonyCameraDevices
{
    NSMutableArray *array = [NSMutableArray array];
    for (SonyCameraService *service in self.sonyCameraServices) {
        SonyCameraDevice *device = [SonyCameraDevice new];
        device.serviceId = service.serviceId;
        device.deviceName = service.name;
        [array addObject:device];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"SonyCamera.dat"];
    
    if (array.count == 0) {
        [[NSFileManager new] removeItemAtPath:path error:NULL];
    } else {
        NSMutableData *data = [NSMutableData data];
        
        NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [encoder encodeObject:array forKey:@"devices"];
        [encoder finishEncoding];
        
        [data writeToFile:path atomically:YES];
    }
}

- (void) loadSonyCameraDevices
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"SonyCamera.dat"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSMutableData *data  = [NSMutableData dataWithContentsOfFile:path];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSArray *array = [decoder decodeObjectForKey:@"devices"];
        
        for (SonyCameraDevice *device in array) {
            SonyCameraService *service = [[SonyCameraService alloc] initWithServiceId:device.serviceId
                                                                           deviceName:device.deviceName
                                                                               plugin:self.plugin];
            [self.sonyCameraServices addObject:service];
        }
    }
}

#pragma mark - SonyCameraReachability Methods

// 通知を受け取るメソッド
-(void) notifiedNetworkStatus:(NSNotification *)notification {
    if ([self checkSSID]) {
        [self connectSonyCamera];
    } else {
        [self disconnectSonyCamera];
    }
}


#pragma mark - SampleDiscoveryDelegate

- (void) didReceiveDeviceList:(BOOL)discovery {
    self.searchFlag = NO;

    if (discovery) {
        SonyCameraService *service = [self foundSonyCamera];
        if (service) {
            [service setOnline:YES];
        }
        
        [DeviceList selectDeviceAt:0];
        
        self.remoteApi = [SonyCameraRemoteApiUtil new];
        self.remoteApi.delegate = self;
    }

    [self.delegate didDiscoverDeviceList:discovery];
}

#pragma mark - SonyCameraRemoteApiUtilDelegate

- (void) didReceivedImage:(NSString *)imageUrl {
    [self.delegate didTakePicture:imageUrl];
}

@end
