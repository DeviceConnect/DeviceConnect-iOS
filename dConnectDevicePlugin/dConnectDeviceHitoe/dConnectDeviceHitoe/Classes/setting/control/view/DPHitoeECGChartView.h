//
//  ECGChartView.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>

@interface DPHitoeECGChartView : UIView
- (void)setupWithDataMax:(int)dMax valueMin:(double)vMin valueMax:(double)vMax;
- (void)drawPointWithIndex:(int)index pulse:(double)pulse;
- (void)drawPointNow;
@end
