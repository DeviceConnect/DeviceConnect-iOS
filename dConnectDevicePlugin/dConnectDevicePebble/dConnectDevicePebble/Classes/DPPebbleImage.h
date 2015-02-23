//
//  DPPebbleImage.h
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DPPebbleImage : NSObject

/*!
 @brief pebble用の画像にコンバート。
 @param　data 表示する変換前の画像
 @param x x座標
 @param y y座標
 @param mode モード
 */
+(NSData*)convertImage: (NSData*)data
                     imageX: (double)imageX
                     imageY: (double)imageY
                  mode: (NSString *)mode;

@end
