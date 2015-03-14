//
//  DPPebbleImage.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleImage.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation DPPebbleImage

// pebble表示用の画像サイズ(w)
const NSInteger MaxWidth = 144;

// pebble表示用の画像サイズ(h)
const NSInteger MaxHeight = 168;



/*!
 @brief pebble用の画像にコンバート。
 @param data 表示する変換前の画像
 @param imageX x座標
 @param imageY y座標
 @param mode モード
 */
+(NSData*)convertImage: (NSData*)data
                imageX:(double)imageX
                imageY:(double)imageY
                  mode: (NSString *)mode
{
    UIImage* image = [[UIImage alloc] initWithData:data];
    if (!image) {
        return nil;
    }
    
    if (image.size.width <= 0 || image.size.height <= 0) {
        return nil;
    }
    
    // display size
    CGSize displaySize = CGSizeMake(MaxWidth, MaxHeight);
    
    // start draw
    UIGraphicsBeginImageContextWithOptions(displaySize, NO, 1.0);
    
    // drawing process by mode
    BOOL proc = NO;
    if (mode == nil || [mode isEqualToString:@""]) {
        
        // same scale
        [image drawInRect:CGRectMake(imageX, imageY, image.size.width, image.size.height)];
        proc = YES;
        
    } else if ([mode isEqualToString: DConnectCanvasProfileModeScales]) {
        
        // fill screen, center image
        CGFloat xForScaledImage, yForScaledImage;
        UIImage *scaledImage = [self scaledImageInDisplayArea: image
                                              xForscaledImage: &xForScaledImage
                                              yForscaledImage: &yForScaledImage];
        
        // draw fill image
        [scaledImage drawInRect: CGRectMake(xForScaledImage,
                                            yForScaledImage,
                                            scaledImage.size.width,
                                            scaledImage.size.height)];
        proc = YES;
        
    } else if ([mode isEqualToString: DConnectCanvasProfileModeFills]) {
        
        // fill screen by same scaled image
        for (CGFloat y = 0; y <= displaySize.height; y += image.size.height) {
            for (CGFloat x = 0; x <= displaySize.width; x += image.size.width) {
                [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
            }
        }
        proc = YES;
    } else {
        proc = NO;
    }
    
    // finish draw
    UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // no draw
    if (!proc) {
        return nil;
    }
    
    // convert CIImage
    CIImage *dstCIImage = [CIImage imageWithCGImage:dstImage.CGImage];
    
    // monochrome filter
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"
                                    keysAndValues:kCIInputImageKey, dstCIImage, nil];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage]
                                       fromRect:[[ciFilter outputImage] extent]];
    UIImage *monochromeImage = [UIImage imageWithCGImage:cgimg
                                                   scale:1
                                             orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);
    
    return [DPPebbleImage convert: monochromeImage];
}

/*!
 @brief imageを元に、スケーリングして画面いっぱいに表示されるUIImageを作成して返す。
        配置座標も返す.
 @param image ディスプレイに表示される元画像
 @param xForscaledImage 拡縮した画像を画面中央に表示する座標(x)を返す領域ポインタ
 @param yForscaledImage 拡縮した画像を画面中央に表示する座標(y)を返す領域ポインタ
 @return 拡縮した画像
 */
+ (UIImage *)scaledImageInDisplayArea: (UIImage *)image
                      xForscaledImage: (CGFloat *)xForscaledImage
                      yForscaledImage: (CGFloat *)yForscaledImage {
    
    // display size
    CGSize displaySize = CGSizeMake(MaxWidth, MaxHeight);
    
    // image size
    CGFloat getSizeW = image.size.width;
    CGFloat getSizeH = image.size.height;
    
    // calculate scale. longer length (width or height) to fit on the screen.
    CGFloat width = displaySize.width;
    CGFloat height = displaySize.height;
    CGFloat widthRatio = getSizeW / displaySize.width;
    CGFloat heightRatio = getSizeH / displaySize.height;
    BOOL isFitWidth = widthRatio > heightRatio;
    CGFloat scale;
    if (isFitWidth) {
        scale = width / getSizeW;
    } else {
        scale = height / getSizeH;
    }
    
    // target size.
    int targetW = (int) ceil(scale * getSizeW);
    int targetH = (int) ceil(scale * getSizeH);
    
    // calculate position of image.
    CGFloat startGridX = 0;
    CGFloat startGridY = 0;
    if (isFitWidth) {
        startGridY = (height / 2 - targetH / 2);
    } else {
        startGridX = (width / 2 - targetW / 2);
    }
    
    // start draw
    UIGraphicsBeginImageContextWithOptions(displaySize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw scaled image. position is (0, 0).
    CGContextScaleCTM(context, scale, scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // finish draw
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    *xForscaledImage = startGridX;
    *yForscaledImage = startGridY;
    return scaledImage;
}



/*!
 @brief GBitmapへ変換。
 @param　image 表示する変換前の画像
 */
+ (NSData*)convert:(UIImage*)image
{
    NSMutableData *data = [NSMutableData data];
    int width = image.size.width;
    int height = image.size.height;
    
    // row_size_bytes
    int row_size_bytes = (width + 31) / 32;
    row_size_bytes *= 4;
    [data appendBytes:&row_size_bytes length:2];
    
    // info_flags
    Byte info_flags[2] = {0, 0x10};
    [data appendBytes:info_flags length:2];
    
    // pos
    UInt16 pos[2] = {0, 0};
    [data appendBytes:pos length:4];
    
    // size
    UInt16 size[2] = {width, height};
    [data appendBytes:size length:4];
    
    // image data
    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8 *rawData = CFDataGetBytePtr(pixelData);
    
    // データ書き込み
    for (int y = 0; y < height; ++y) {
        int currentBit = 0;
        Byte buff = 0;
        for (int x = 0; x < row_size_bytes * 8; ++x) {
            if (x < width) {
                int pixelInfo = (int)bytesPerRow * y + x * 4; // The image is png
                UInt8 red = rawData[pixelInfo];
                //UInt8 g = rawData[pixelInfo+1];
                //UInt8 b = rawData[pixelInfo+2];
                UInt8 alpha = rawData[pixelInfo+3];
                
                if (alpha < 127) {
                    // 透明
                    buff = buff | (0x01 << currentBit);
                } else {
                    // 白黒（白黒フィルタがかかっているのでOK!）
                    // ランダムディザ
                    if (red>150) {
                        buff = buff | (0x01 << currentBit);
                    } else if (red>110 && rand() % 255 < red) {
                        buff = buff | (0x01 << currentBit);
                    }
                }
            }
            
            // データ書き込み
            currentBit++;
            if (currentBit>7) {
                [data appendBytes:&buff length:1];
                currentBit = 0;
                buff = 0;
            }
        }
    }
    
    return data;
}

@end
