//
//  DPHostCanvasDrawObject.h
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DPHostCanvasDrawObject : NSObject

/*!
 drawing process. override in deriverd class.
 @param displaySize display size
 */
- (void)draw: (CGSize) displaySize;

@end
