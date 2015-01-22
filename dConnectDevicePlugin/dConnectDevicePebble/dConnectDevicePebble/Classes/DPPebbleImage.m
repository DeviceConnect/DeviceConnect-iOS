//
//  DPPebbleImage.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleImage.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation DPPebbleImage

/*!
 @define pebble表示用の画像サイズ
 */
#define MaxWidth 144
#define MaxHeight 120



/*!
 @brief pebble用の画像にコンバート。
 @param data 表示する変換前の画像
 @param x x座標
 @param y y座標
 @param mode モード
 */
+(NSData*)convertImage: (NSData*)data
                     x: (double)x
                     y: (double)y
                  mode: (NSString *)mode
{
	UIImage* image = [[UIImage alloc] initWithData:data];
	if (!image) {
		return nil;
	}
    
    if (image.size.width <= 0 || image.size.height <= 0) {
        return nil;
    }
	
    /* ディスプレイサイズ */
    CGSize displaySize = CGSizeMake(MaxWidth, MaxHeight);
    
    /* 描画処理開始 */
    UIGraphicsBeginImageContextWithOptions(displaySize, NO, 1.0);
    
    /* モード別に描画処理を行う */
    BOOL proc = NO;
    if (mode == nil || [mode isEqualToString:@""]) {
        
        /* 等倍で(x, y)に画像を描画する */
        [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
        proc = YES;
        
    } else if ([mode isEqualToString: DConnectCanvasProfileModeScales]) {
        
        /* 画面いっぱいになるよう拡縮した画像および画像が画面中央に配置される表示座標を取得 */
        CGFloat xForScaledImage, yForScaledImage;
        UIImage *scaledImage = [self scaledImageInDisplayArea: image xForscaledImage: &xForScaledImage yForscaledImage: &yForScaledImage];
        
        /* 縮尺変更後の画像を配置して描画する */
        [scaledImage drawInRect: CGRectMake(xForScaledImage, yForScaledImage, scaledImage.size.width, scaledImage.size.height)];
        proc = YES;
        
    } else if ([mode isEqualToString: DConnectCanvasProfileModeFills]) {
        
        /* 等倍で画像を敷き詰めて描画する */
        for (CGFloat y = 0; y <= displaySize.height; y += image.size.height) {
            for (CGFloat x = 0; x <= displaySize.width; x += image.size.width) {
                [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
            }
        }
        proc = YES;
    }
    
    /* 描画処理終了 */
    UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    /* 処理しなかったらnilを返す */
    if (!proc) {
        return nil;
    }
    
    // CIImageに変換
    CIImage *dstCIImage = [CIImage imageWithCGImage:dstImage.CGImage];
    
	// 白黒フィルタ
	CIFilter *ciFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"
									keysAndValues:kCIInputImageKey, dstCIImage, nil];
	CIContext *ciContext = [CIContext contextWithOptions:nil];
	CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
	UIImage *monochromeImage = [UIImage imageWithCGImage:cgimg scale:1 orientation:UIImageOrientationUp];
	CGImageRelease(cgimg);
	
	return [DPPebbleImage convert: monochromeImage];
}

/*!
 @brief imageを元に、スケーリングして画面いっぱいに表示されるUIImageを作成して返す。配置座標も返す.
 @param image ディスプレイに表示される元画像
 @param xForscaledImage 拡縮した画像を画面中央に表示する座標(x)を返す領域ポインタ
 @param yForscaledImage 拡縮した画像を画面中央に表示する座標(y)を返す領域ポインタ
 @return 拡縮した画像
 */
+ (UIImage *)scaledImageInDisplayArea: (UIImage *)image
                      xForscaledImage: (CGFloat *)xForscaledImage
                      yForscaledImage: (CGFloat *)yForscaledImage {
    
    /* ディスプレイサイズ */
    CGSize displaySize = CGSizeMake(MaxWidth, MaxHeight);
    
    // 画像サイズ取得
    CGFloat getSizeW = image.size.width;
    CGFloat getSizeH = image.size.height;
    
    // 拡大率:縦横で長い方(割合で求める)が画面ピッタリになるように
    CGFloat width = displaySize.width;
    CGFloat height = displaySize.height;
    CGFloat widthRatio = getSizeW / displaySize.width;
    CGFloat heightRatio = getSizeH / displaySize.height;
    BOOL isFitWidth = widthRatio > heightRatio ? YES : NO;
    CGFloat scale;
    if (isFitWidth) {
        scale = width / getSizeW;
    } else {
        scale = height / getSizeH;
    }
    
    // 目標の大きさ
    int targetW = (int) ceil(scale * getSizeW);
    int targetH = (int) ceil(scale * getSizeH);
    
    // 画像描写開始位置の修正
    CGFloat startGridX = 0;
    CGFloat startGridY = 0;
    if (isFitWidth) {
        startGridY = (height / 2 - targetH / 2);
    } else {
        startGridX = (width / 2 - targetW / 2);
    }
    
    /* 描画開始 */
    UIGraphicsBeginImageContextWithOptions(displaySize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* 縮尺変更して描画 (0, 0)に拡大縮小した図形を描画する */
    CGContextScaleCTM(context, scale, scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    /* 描画終了 */
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
	int w = image.size.width;
	int h = image.size.height;
	
	// row_size_bytes
	int row_size_bytes = (w + 31) / 32;
	row_size_bytes *= 4;
	[data appendBytes:&row_size_bytes length:2];
	
	// info_flags
	Byte info_flags[2] = {0, 0x10};
	[data appendBytes:info_flags length:2];
	
	// pos
	UInt16 pos[2] = {0, 0};
	[data appendBytes:pos length:4];
	
	// size
	UInt16 size[2] = {w, h};
	[data appendBytes:size length:4];
	
	// image data
	size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
	CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
	const UInt8 *rawData = CFDataGetBytePtr(pixelData);
	
	// データ書き込み
	for (int y = 0; y < h; ++y) {
		int currentBit = 0;
		Byte buff = 0;
		for (int x = 0; x < row_size_bytes * 8; ++x) {
			if (x < w) {
				int pixelInfo = (int)bytesPerRow * y + x * 4; // The image is png
				UInt8 r = rawData[pixelInfo];
				//UInt8 g = rawData[pixelInfo+1];
				//UInt8 b = rawData[pixelInfo+2];
				UInt8 a = rawData[pixelInfo+3];
				
				if (a < 127) {
					// 透明
					buff = buff | (0x01 << currentBit);
				} else {
					// 白黒（白黒フィルタがかかっているのでrでOK!）
					// ランダムディザ
					if (r>150) {
						buff = buff | (0x01 << currentBit);
					} else if (r>110) {
						if (rand()%255<r) {
							buff = buff | (0x01 << currentBit);
						}
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
