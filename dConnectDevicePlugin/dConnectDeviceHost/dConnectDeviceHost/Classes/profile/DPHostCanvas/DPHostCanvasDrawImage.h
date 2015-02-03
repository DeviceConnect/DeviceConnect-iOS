//
//  DPHostCanvasDrawImage.h
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasDrawObject.h"
#import <UIKit/UIKit.h>

@interface DPHostCanvasDrawImage : DPHostCanvasDrawObject

/*!
 initialize.
 @param data image data
 @param x x
 @param y y
 @param mode mode
 */
- (id)initWithParameter: (NSData *)data x: (double)x y: (double)y mode: (NSString *)mode;


@end


