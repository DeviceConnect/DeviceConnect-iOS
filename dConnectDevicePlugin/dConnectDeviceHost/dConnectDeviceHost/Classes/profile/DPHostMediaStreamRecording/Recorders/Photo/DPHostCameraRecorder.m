//
//  DPHostCameraRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UserNotifications/UserNotifications.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "DPHostCameraRecorder.h"
#import "DPHostRecorder.h"
#import "DPHostUtils.h"
#import "DPHostRecorderUtils.h"

static NSString *const kDPHostStartPreviewNotificationId = @"kDPHostStartPreviewNotificationId";
@interface DPHostCameraRecorder()<UNUserNotificationCenterDelegate>
@property (nonatomic) DPHostSimpleHttpServer *httpServer;
/// Preview APIでプレビュー画像URIの配送を行うかどうか。
@property (nonatomic) BOOL sendPreview;
/// 前回プレビューを送った時間。
@property (nonatomic) CMTime lastPreviewTimestamp;
/// Preview APIでプレビュー画像URIの配送を行うインターバル（秒）。
@property (nonatomic) CMTime secPerFrame;

@end
@implementation DPHostCameraRecorder

- (instancetype)initWithRecorderId:(NSNumber*)recorderId
                       videoDevice:(AVCaptureDevice*)videoDevice
                       audioDevice:(AVCaptureDevice*)audioDevice
{
    self = [super initWithRecorderId:recorderId videoDevice:videoDevice audioDevice:audioDevice];
    if (self) {
        self.recorderId = [NSString stringWithFormat:@"photo_%d", [recorderId intValue]];
    }
    return self;
}


- (void)initialize
{
    [super initialize];
    self.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"jpg"];
    self.state = DPHostRecorderStateInactive;
    self.sendPreview = NO;
    self.secPerFrame = CMTimeMake(2, 1000);
    [self setPhotoDataSourceType];
    [self setVideoSourceTypeWithDelegate:self];
    NSMutableString *name = @"iOSHost Camera Recorder-".mutableCopy;
    
    switch (self.videoCaptureDevice.position) {
        case AVCaptureDevicePositionBack:
            [name appendString:@"back"];
            break;
        case AVCaptureDevicePositionFront:
            [name appendString:@"front"];
            break;
        case AVCaptureDevicePositionUnspecified:
        default:
            [name appendString:@"unknown"];
            break;
    }
    self.name = [NSString stringWithString:name];
    NSArray *cameraSizes = [DPHostRecorderUtils getRecorderSizesForSession:self.session];
    self.supportedPictureSizes = cameraSizes.mutableCopy;
    self.supportedPreviewSizes = cameraSizes.mutableCopy;
    self.pictureSize = [DPHostRecorderUtils getDimensionForPreset:AVCaptureSessionPreset640x480];
    self.previewSize = [DPHostRecorderUtils getDimensionForPreset:AVCaptureSessionPreset640x480];
    self.supportedMimeTypes = @[self.mimeType];
}

- (void)clean
{
    [self stopWebServer];
}


- (BOOL)isSupportedPictureSizeWithWidth:(int)width height:(int)height
{
    CGSize size = [DPHostRecorderUtils getDimensionForPreset:[NSString stringWithFormat:@"%dx%d", width, height]];
    return (size.width != -1 && size.height != -1);
}
- (BOOL)isSupportedPreviewSizeWithWidth:(int)width height:(int)height
{
    CGSize size = [DPHostRecorderUtils getDimensionForPreset:[NSString stringWithFormat:@"%dx%d", width, height]];
    return (size.width != -1 && size.height != -1);
}



- (void)takePhotoWithSuccessCompletion:(void (^)(NSURL *assetURL))successCompletion
                        failCompletion:(void (^)(NSString *errorMessage))failCompletion
{
    __weak DPHostCameraRecorder *weakSelf = self;
    if (self.photoConnection.supportsVideoOrientation) {
        self.photoConnection.videoOrientation = [DPHostRecorderUtils videoOrientationFromDeviceOrientation:[UIDevice currentDevice].orientation];
    }
    __block NSError *error = nil;
    [self performWriting:
     ^{
         if (![weakSelf.session isRunning]) {
             [weakSelf.session startRunning];
         }
         
         // ライトが点いていたら消灯する。
         [DPHostRecorderUtils setLightOnOff:NO];
         // 写真を撮影する。
         [weakSelf takePhotoInternalWithError:&error];
         if (error) {
             if ([weakSelf.session isRunning]) {
                 [weakSelf.session stopRunning];
             }
             if (failCompletion) {
                 failCompletion(error.localizedDescription);
             }
             return;
         }
         [weakSelf saveFileWithCompletionHandler:^(NSURL *assetURL, NSError *error) {
             
             if ([weakSelf.session isRunning] && !weakSelf.sendPreview) {
                 [weakSelf.session stopRunning];
             }
             if (error) {
                 failCompletion(error.localizedDescription);
             } else {
                 successCompletion(assetURL);
             }

         }];
     }];
}
- (BOOL)isBack
{
    return (self.videoCaptureDevice.position == AVCaptureDevicePositionBack);
}
- (void)turnOnFlashLight
{
    [DPHostRecorderUtils setLightOnOff:YES];
}
- (void)turnOffFlashLight
{
    [DPHostRecorderUtils setLightOnOff:NO];
}
- (BOOL)getFlashLightState
{
    return [self useLight];
}
- (BOOL)useFlashLight
{
    return [self useLight];
}
- (void)startWebServerWithSuccessCompletion:(void (^)(NSString *uri))successCompletion
                             failCompletion:(void (^)(NSString *errorMessage))failCompletion
{
    if (self.httpServer) {
        [self.httpServer stop];
        self.httpServer = nil;
    }
    
    self.httpServer = [DPHostSimpleHttpServer new];
    self.httpServer.listenPort = 9000;
    BOOL result = [self.httpServer start];
    if (!result) {
        failCompletion(@"MJPEG Server cannot running.");
        return;
    }
    NSError *error = nil;
    [self startRecordingWithError:&error];
    if (error) {
        failCompletion(error.localizedDescription);
        return;
    }
    // プレビュー画像URIの配送処理が開始されていないのなら、開始する。
    self.sendPreview = YES;
    self.lastPreviewTimestamp = kCMTimeInvalid;
    NSString *url = [self.httpServer getUrl];
    if (!url) {
        [self.httpServer stop];
        self.httpServer = nil;
        failCompletion(@"MJPEG Server cannot running.");
        return;
    }
    [self showPreviewNotification];
    successCompletion(url);
}

- (void)stopWebServer
{
    if (self.httpServer) {
        [self.httpServer stop];
        self.httpServer = nil;
    }
    [self finishRecordingSample];
    // イベント受領先が存在しないなら、プレビュー画像URIの配送処理を停止する。
    self.sendPreview = NO;
    // 次回プレビュー開始時に影響を与えない為に、初期値（無効値）を設定する。
    self.lastPreviewTimestamp = kCMTimeInvalid;
    [self hidePreviewNotification];
}

#pragma mark - Private Method
#pragma mark - TakePhoto Internal
// 写真撮影
- (void)takePhotoInternalWithError:(NSError**)error
{
    [self.videoCaptureDevice lockForConfiguration:error];
    
    if (!*error) {
        if (self.videoCaptureDevice.focusMode != AVCaptureFocusModeContinuousAutoFocus &&
            [self.videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        } else if (self.videoCaptureDevice.focusMode != AVCaptureFocusModeAutoFocus &&
                   [self.videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            self.videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        } else if (self.videoCaptureDevice.focusMode != AVCaptureFocusModeLocked &&
                   [self.videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeLocked]) {
            self.videoCaptureDevice.focusMode = AVCaptureFocusModeLocked;
        }
        if (self.videoCaptureDevice.exposureMode != AVCaptureExposureModeContinuousAutoExposure &&
            [self.videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.videoCaptureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        } else if (self.videoCaptureDevice.exposureMode != AVCaptureExposureModeAutoExpose &&
                   [self.videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            self.videoCaptureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
        } else if (self.videoCaptureDevice.exposureMode != AVCaptureExposureModeLocked &&
                   [self.videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeLocked]) {
            self.videoCaptureDevice.exposureMode = AVCaptureExposureModeLocked;
        }
        if (self.videoCaptureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance &&
            [self.videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            self.videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        } else if (self.videoCaptureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeAutoWhiteBalance &&
                   [self.videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            self.videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        } else if (self.videoCaptureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeLocked &&
                   [self.videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            self.videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
        }
        if (self.videoCaptureDevice.automaticallyEnablesLowLightBoostWhenAvailable != NO &&
            self.videoCaptureDevice.lowLightBoostSupported) {
            self.videoCaptureDevice.automaticallyEnablesLowLightBoostWhenAvailable = YES;
        }
        [self.videoCaptureDevice unlockForConfiguration];
        
        [NSThread sleepForTimeInterval:0.5];
    }
}

// 写真の保存
- (void)saveFileWithCompletionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler
{
    __block void (^takephotoBlock) (void) = ^(void){
        AVCaptureStillImageOutput *stillImageOutput = (AVCaptureStillImageOutput *)self.photoConnection.output;
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:self.photoConnection
                                                      completionHandler:
         ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
             __block NSError *err = nil;
             if (!imageDataSampleBuffer || error) {
                 err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to take a photo."];
                 completionHandler(nil, err);
                 return;
             }
             NSData *jpegData;
             @try {
                 jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             }
             @catch (NSException *exception) {
                 NSString *message;
                 if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
                     message = @"Non-JPEG data was given.";
                 } else {
                     message = [NSString stringWithFormat:@"%@ encountered.", [exception name]];
                 }
                 err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:message];
                 completionHandler(nil, err);
                 return;
             }
             
             // EXIF情報を水平に統一する。ブラウザによってはEXIF情報により画像の向きが変わるため。
             CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpegData, NULL);
             NSDictionary *metadata = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
             NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:metadata];
             NSMutableDictionary *tiff = meta[(NSString*) kCGImagePropertyTIFFDictionary];
             tiff[(NSString*) kCGImagePropertyTIFFOrientation] = @(kCGImagePropertyOrientationUp);
             meta[(NSString*) kCGImagePropertyTIFFDictionary] = tiff;
             meta[(NSString*) kCGImagePropertyOrientation] = @(kCGImagePropertyOrientationUp);
             UIImage *jpeg = [[UIImage alloc] initWithData:jpegData];
             UIImage *fixJpeg = [DPHostRecorderUtils fixOrientationWithImage:jpeg position:self.videoCaptureDevice.position];
             NSData* imageData = UIImageJPEGRepresentation(fixJpeg, 1.0f);
             CGImageSourceRef fixSource = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
             NSString *tmpName = NSProcessInfo.processInfo.globallyUniqueString;
             __block NSURL *tmpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.jpeg", NSTemporaryDirectory(), tmpName]];
             CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef) tmpUrl, kUTTypeJPEG, 1, nil);

             CGImageDestinationAddImageFromSource(destination, fixSource, 0, (__bridge CFDictionaryRef) meta);
             CGImageDestinationFinalize(destination);
             if (source) {
                 CFRelease(source);
             }
             if (fixSource) {
                 CFRelease(fixSource);
             }
             if (destination) {
                 CFRelease(destination);
             }
             __block PHObjectPlaceholder *placeHolder;
             [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                 PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:tmpUrl];
                 placeHolder = [assetRequest placeholderForCreatedAsset];
             }   completionHandler:^(BOOL success, NSError *error) {
                 if (!success) {
                     err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:error.localizedDescription];
                     completionHandler(nil, err);
                     return;
                 }
                 [[NSFileManager defaultManager] removeItemAtURL:tmpUrl error:&err];
                 
                 completionHandler([NSURL URLWithString:placeHolder.localIdentifier], err);
             }];
             
         }];
    };
    // PHPPhotoLibraryの許可を取れているか
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
        default:
            break;
        case PHAuthorizationStatusNotDetermined:
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            dispatch_async(dispatch_get_main_queue(), ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                    switch (status) {
                        case PHAuthorizationStatusNotDetermined:
                        case PHAuthorizationStatusRestricted:
                        case PHAuthorizationStatusDenied:
                            completionHandler(nil, [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Not Authorized to take photo."]);
                            return;
                        case PHAuthorizationStatusAuthorized:
                        default:
                            break;
                    }
                    takephotoBlock();
                }];

            });
            return;
            
    }
    takephotoBlock();

}


- (BOOL)useLight
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL useFlashLight = NO;
    [captureDevice lockForConfiguration:NULL];
    useFlashLight = (captureDevice.torchMode == AVCaptureTorchModeOn);
    [captureDevice unlockForConfiguration];
    return useFlashLight;
}
#pragma mark - AVCapture{Audio,Video}DataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (self.sendPreview) {
        CMSampleBufferRef buffer = sampleBuffer;
        CMTime originalSampleBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer);
        if (!CMTIME_IS_NUMERIC(originalSampleBufferTimestamp)) {
            return;
        }
        BOOL requireRelease = NO;
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(buffer);
        [self initVideoConnection:connection formatDescription:formatDescription];
        if (CMTIME_IS_INVALID(self.lastPreviewTimestamp)) {
            // まだプレビューの配送を行っていないのであれば、プレビューを配信する。
            [self sendPreviewDataWithSampleBuffer:sampleBuffer];
        } else if (CMTIME_IS_NUMERIC(self.lastPreviewTimestamp)) {
            CMTime elapsedTime =
            CMTimeSubtract(self.lastPreviewTimestamp, originalSampleBufferTimestamp);
            if (CMTIME_COMPARE_INLINE(elapsedTime, >=, self.secPerFrame)) {
                // 規定時間が経過したのであれば、プレビューを配信する。
                [self sendPreviewDataWithSampleBuffer:sampleBuffer];
            }
        } else {
            self.lastPreviewTimestamp = originalSampleBufferTimestamp;
        }
        if (requireRelease) {
            CFRelease(buffer);
        }
    }
}

- (void) sendPreviewDataWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!imageBuffer) {
            return;
        }
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        if (!ciImage) {
            return;
        }
        
        UIImage *image = [UIImage imageWithCIImage:ciImage];
        CGSize size = image.size;
        double scale = 320000.0 / (size.width * size.height);
        size = CGSizeMake((int)(size.width * scale), (int)(size.height * scale));
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
        
        [self.httpServer offerData:jpegData];
    }
    
}

#pragma mark - Notification Control
- (void)showPreviewNotification
{
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title    = @"カメラ撮影中(iOS Host Camera Preview)";
    content.body     = @"タップして撮影を停止します。";
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1
                                                  repeats:NO];
    UNNotificationRequest* nRequest = [UNNotificationRequest
                                       requestWithIdentifier:kDPHostStartPreviewNotificationId
                                                     content:content
                                                     trigger:trigger];
    
    // Schedule the notification.
    dispatch_async(dispatch_get_main_queue(), ^{
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center addNotificationRequest:nRequest
                 withCompletionHandler:^(NSError * _Nullable error) {
                 }];

    });
}

- (void)hidePreviewNotification
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        for (UNNotification *notification in notifications) {
            NSString *currentId = notification.request.identifier;
            if ([currentId isEqualToString:kDPHostStartPreviewNotificationId]) {
                [center removeDeliveredNotificationsWithIdentifiers:@[kDPHostStartPreviewNotificationId]];
                return;
            }
        }
    }];
    
}
#pragma mark - Notification Delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    completionHandler();
    [self stopWebServer];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound |
                      UNNotificationPresentationOptionAlert);
};
@end
