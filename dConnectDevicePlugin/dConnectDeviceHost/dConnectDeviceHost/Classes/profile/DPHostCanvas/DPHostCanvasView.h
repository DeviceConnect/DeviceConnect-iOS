//
//  DPHostCanvasView.h
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPHostCanvasDrawObject.h"

@interface DPHostCanvasView : UIView

/*!
 set draw object.
 @param drawObject draw object
 */
- (void)setDrawObject: (DPHostCanvasDrawObject *) drawObject;

    
@end
