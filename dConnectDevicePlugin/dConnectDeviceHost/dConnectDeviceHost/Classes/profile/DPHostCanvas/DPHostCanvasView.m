//
//  DPHostCanvasView.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasView.h"
#import <DConnectSDK/DConnectSDK.h>

@interface DPHostCanvasView() {
    DPHostCanvasDrawObject *_drawObject;
}

@end

@implementation DPHostCanvasView

- (instancetype)initWithFrame:(CGRect)frame {
    
    _drawObject = nil;

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setDrawObject: (DPHostCanvasDrawObject *) drawObject {
    _drawObject = drawObject;
    /* redraw */
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // display size
    CGSize displaySize = self.frame.size;
    
    // fill background
    CGContextSetFillColor(context, CGColorGetComponents(self.backgroundColor.CGColor));
    CGContextFillRect(context, self.frame);
    
    // draw
    if (_drawObject != nil) {
        [_drawObject draw: displaySize];
    }
}

@end
