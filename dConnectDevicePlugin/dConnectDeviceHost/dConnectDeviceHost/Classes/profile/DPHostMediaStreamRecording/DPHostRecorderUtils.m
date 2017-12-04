//
//  DPHostRecorderUtils.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostRecorderUtils.h"

@implementation DPHostRecorderUtils
+ (UIImage *)fixOrientationWithImage:(UIImage *)image position:(AVCaptureDevicePosition) position
{
    
    if (image.imageOrientation == UIImageOrientationUp && position != AVCaptureDevicePositionFront) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (position) {
        case AVCaptureDevicePositionFront:
            switch (image.imageOrientation) {
                    
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, 0, image.size.width);
                    transform = CGAffineTransformScale(transform, 1, -1);
                    break;
                case UIImageOrientationDown:
                case UIImageOrientationDownMirrored:
                case UIImageOrientationUp:
                case UIImageOrientationUpMirrored:
                default:
                    transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
            }
            
            break;
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionBack:
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


+(AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationUnknown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

+ (CGSize)getDimensionForPreset:(NSString *)preset
{
    if ([preset isEqualToString:AVCaptureSessionPreset352x288]) {
        return CGSizeMake(288, 352);
    } else if ([preset isEqualToString:AVCaptureSessionPreset640x480]) {
        return CGSizeMake(480, 640);
    } else if ([preset isEqualToString:AVCaptureSessionPreset1280x720]) {
        return CGSizeMake(720, 1280);
    } else if ([preset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        return CGSizeMake(1080, 1920);
    } else if ([preset isEqualToString:AVCaptureSessionPreset3840x2160]) {
        return CGSizeMake(2160, 3840);
    }
    return CGSizeMake(-1.0, -1.0);
}

+ (NSArray*)getRecorderSizesForSession:(AVCaptureSession*)session
{
    
    NSMutableArray *dimensionArr =
    @[
      AVCaptureSessionPreset352x288,
      AVCaptureSessionPreset640x480,
      AVCaptureSessionPreset1280x720,
      AVCaptureSessionPreset1920x1080,
      AVCaptureSessionPreset3840x2160
      ].mutableCopy;
    NSMutableArray *cameraSizes = [NSMutableArray array];
    for (size_t i = 0; i < dimensionArr.count; ++i) {
        if (![session canSetSessionPreset:dimensionArr[i]]) {
            [dimensionArr removeObjectAtIndex:i];
        } else {
            [cameraSizes addObject:[NSValue valueWithCGSize:[DPHostRecorderUtils getDimensionForPreset:dimensionArr[i]]]];
        }
    }
    return cameraSizes.mutableCopy;
    
}

+ (BOOL)containsDevice:(AVCaptureDevice *)device session:(AVCaptureSession *)session
{
    BOOL found = NO;
    for (AVCaptureDeviceInput *input in [session inputs]) {
        if ([[input device].uniqueID isEqualToString:device.uniqueID]) {
            found = YES;
            break;
        }
    }
    return found;
}

+ (AVCaptureConnection *)connectionForDevice:(AVCaptureDevice *)device output:(AVCaptureOutput *)output
{
    if (!device || !output) {
        NSLog(@"args must be non-nil.");
        return nil;
    }
    
    for (AVCaptureConnection *connection in [output connections]) {
        BOOL found = NO;
        for (AVCaptureInputPort *inputPort in [connection inputPorts]) {
            AVCaptureInput *input = [inputPort input];
            if ([input isKindOfClass:[AVCaptureDeviceInput class]]
                && [[(AVCaptureDeviceInput *)input device].uniqueID isEqualToString:device.uniqueID]) {
                found = YES;
                break;
            }
        }
        if (found) {
            return connection;
        }
    }
    return nil;
}

+ (void)setLightOnOff:(BOOL)bSwitch
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice isTorchAvailable]
        && [captureDevice isTorchModeSupported:AVCaptureTorchModeOn]
        && [captureDevice isTorchModeSupported:AVCaptureTorchModeOff]) {
        [captureDevice lockForConfiguration:NULL];
        if (bSwitch) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
        } else {
            captureDevice.torchMode = AVCaptureTorchModeOff;
        }
        [captureDevice unlockForConfiguration];
    }
}
@end
