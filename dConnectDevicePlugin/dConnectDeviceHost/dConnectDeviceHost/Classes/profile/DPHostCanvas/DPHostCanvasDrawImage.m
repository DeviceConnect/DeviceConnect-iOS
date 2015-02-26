//
//  DPHostCanvasDrawImage.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasDrawImage.h"
#import <DConnectSDK/DConnectSDK.h>

@interface DPHostCanvasDrawImage() {
    NSData *_data;
    double _x;
    double _y;
    NSString *_mode;
}

@end

@implementation DPHostCanvasDrawImage

- (id)initWithParameter:(NSData *)data
                 imageX:(double)imageX
                 imageY:(double)imageY
                   mode:(NSString *)mode {
    
    _data = data;
    _x = imageX;
    _y = imageY;
    _mode = mode;
    
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (void)draw : (CGSize) displaySize {
    
    if (_data == nil) {
        return;
    }
    
    UIImage* image = [[UIImage alloc] initWithData:_data];
    if (!image) {
        return;
    }
    
    if (image.size.width <= 0 || image.size.height <= 0) {
        return;
    }
    
    // drawing process by mode
    BOOL proc = NO;
    if (_mode == nil || [_mode isEqualToString:@""]) {
        
        // same scale
        [image drawInRect:CGRectMake(_x, _y, image.size.width, image.size.height)];
        proc = YES;
        
    } else if ([_mode isEqualToString: DConnectCanvasProfileModeScales]) {
        
        // fill screen, center image
        CGFloat xForScaledImage, yForScaledImage;
        UIImage *scaledImage = [self scaledImageInDisplayArea: image
                                              xForscaledImage: &xForScaledImage
                                              yForscaledImage: &yForScaledImage
                                                  displaySize: displaySize];
        
        // draw fill image
        [scaledImage drawInRect: CGRectMake(xForScaledImage,
                                            yForScaledImage,
                                            scaledImage.size.width,
                                            scaledImage.size.height)];
        proc = YES;
        
    } else if ([_mode isEqualToString: DConnectCanvasProfileModeFills]) {
        
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
}

/*!
 @brief imageを元に、スケーリングして画面いっぱいに表示されるUIImageを作成して返す。
        配置座標も返す.
 @param image ディスプレイに表示される元画像
 @param xForscaledImage 拡縮した画像を画面中央に表示する座標(x)を返す領域ポインタ
 @param yForscaledImage 拡縮した画像を画面中央に表示する座標(y)を返す領域ポインタ
 @param displaySize 画面サイズ
 @return 拡縮した画像
 */
- (UIImage *)scaledImageInDisplayArea: (UIImage *)image
                      xForscaledImage: (CGFloat *)xForscaledImage
                      yForscaledImage: (CGFloat *)yForscaledImage
                          displaySize: (CGSize) displaySize
{
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

@end
