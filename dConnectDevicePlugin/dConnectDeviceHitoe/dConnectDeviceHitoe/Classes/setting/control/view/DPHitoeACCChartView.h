//
//  DPHitoeACCChartView.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>
#import "DPHitoeAccelerationData.h"
@interface DPHitoeACCChartView : UIView
- (void)setupWithDataMax:(int)dMax valueMin:(double)vMin valueMax:(double)vMax;
- (void)drawPointWithIndex:(int)index pulse:(DPHitoeAccelerationData *)pulse;
- (void)drawPointNow;
@end
