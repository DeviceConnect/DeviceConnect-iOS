//
//  DPHitoeACCChartView.m
//  dConnectDeviceHitoe
//
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <CoreGraphics/CoreGraphics.h>
#import "DPHitoeACCChartView.h"
#import "DPHitoeAccelerationData.h"
#import "DPHitoeConsts.h"

@interface DPHitoeACCChartView() {
    CGFloat graphWidth;
    int graphHeight;
    int interval;
    int graphCenter;
    CGFloat coefficient;
    NSMutableArray *drawPoints;
    int dataMax;
    CGFloat graphStepWidth;
    BOOL drawGuide;
    int yOffset;
    CGFloat yStart;
    CGFloat yEnd;
    CGFloat xInterval;

    CGFloat valueMin;
    CGFloat valueMax;
    CGFloat valueLimit;
    CGFloat valueRed;

    BOOL isReady;

    int indexWriteNeed;
    int indexWritten;

    int prevStepIndex;
    CGFloat prevPoint[3];

    CGImageRef imageBase;
    CGImageRef imagePrev;

    CGRect boundsRect;
    CGAffineTransform affine;
    
    BOOL isDrawActive;
}
@end

@implementation DPHitoeACCChartView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    int indexStart = 0;
    
    if (indexWritten == indexWriteNeed) {
        isDrawActive = NO;
        return;
    } else if (indexWritten < indexWriteNeed) {
        if (imagePrev) {
            CGContextConcatCTM(context, affine);
            CGContextDrawImage(context, boundsRect, imagePrev);
        }
        
        indexStart = indexWritten;
    } else {
        if (imageBase) {
            CGContextConcatCTM(context, affine);
            CGContextDrawImage(context, boundsRect, imageBase);
            CGImageRelease(imagePrev);
            imagePrev = nil;
            imagePrev = CGBitmapContextCreateImage(context);
        }
        
        indexStart = 0;
        
    }
    
    BOOL isFirst = YES;
    CGFloat point[] = {0.0, 0.0, 0.0};
    CGFloat pointPrev = (CGFloat) graphCenter;
    for (indexWritten = indexStart; indexWritten <= indexWriteNeed; indexWritten++) {
        point[0] = 0.0;
        point[1] = 0.0;
        point[2] = 0.0;
        
        DPHitoeAccelerationData *acc = drawPoints[indexWritten];
        if (acc.accelX != -99999999.9) {
            double temp[3];
            temp[0] = acc.accelX;
            temp[1] = acc.accelY;
            temp[2] = acc.accelZ;
            point[0] = (CGFloat) temp[0] * coefficient;
            point[1] = (CGFloat) temp[1] * coefficient;
            point[2] = (CGFloat) temp[2] * coefficient;
        } else {
            continue;
        }
        @autoreleasepool {
            point[0] += pointPrev;
            point[1] += pointPrev;
            point[2] += pointPrev;
            
            point[0] = DPHitoeMin(DPHitoeMax(point[0], yStart), yEnd);
            point[1] = DPHitoeMin(DPHitoeMax(point[1], yStart), yEnd);
            point[2] = DPHitoeMin(DPHitoeMax(point[2], yStart), yEnd);
            
            CGContextSetStrokeColorWithColor(context, [self xColor].CGColor);
            if (isFirst) {
                if (indexStart == 0) {
                    CGContextMoveToPoint(context, 0, pointPrev);
                } else {
                    CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[0]);
                }
            } else {
                CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[0]);
            }
            
            CGContextAddLineToPoint(context, ((CGFloat) indexWritten) * graphStepWidth, point[0]);
            CGContextStrokePath(context);
            prevPoint[0] = point[0];

            CGContextSetStrokeColorWithColor(context, [self yColor].CGColor);
            if (isFirst) {
                if (indexStart == 0) {
                    CGContextMoveToPoint(context, 0, pointPrev);
                } else {
                    CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[1] / 2);
                }
            } else {
                CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[1] / 2);
            }
            
            CGContextAddLineToPoint(context, ((CGFloat) indexWritten) * graphStepWidth, point[1] / 2);
            
            
            CGContextStrokePath(context);
            prevPoint[1] = point[1];
            
            CGContextSetStrokeColorWithColor(context, [self zColor].CGColor);
            if (isFirst) {
                if (indexStart == 0) {
                    CGContextMoveToPoint(context, 0, pointPrev);
                } else {
                    CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[2]);
                }
            } else {
                CGContextMoveToPoint(context, ((CGFloat) prevStepIndex) * graphStepWidth, prevPoint[2]);
            }
            
            CGContextAddLineToPoint(context, ((CGFloat) indexWritten) * graphStepWidth, point[2]);
            CGContextStrokePath(context);
            prevPoint[2] = point[2];
            prevStepIndex = indexWritten;
            
            if (isFirst) {
                isFirst = NO;
            }
        }
    }
    CGImageRelease(imagePrev);
    imagePrev = nil;
    imagePrev = CGBitmapContextCreateImage(context);
    
    isDrawActive = NO;
    
    UIGraphicsEndImageContext();
}

- (void)setupWithDataMax:(int)dMax valueMin:(double)vMin valueMax:(double)vMax {
    isReady = NO;
    drawPoints = [NSMutableArray array];
    prevPoint[0] = 0.0;
    prevPoint[1] = 0.0;
    prevPoint[2] = 0.0;
    drawGuide = NO;
    isReady = NO;
    isDrawActive = NO;
    yOffset = 0;

    double tempValue = 0.0;
    BOOL isMinMinus = NO;
    if (vMin < 0) {
        isMinMinus = YES;
        if (vMin * -1 < vMax) {
            tempValue = vMax;
        } else {
            tempValue = vMin * -1;
        }
    } else {
        if (vMin < vMax) {
            tempValue = vMax;
        } else {
            tempValue = vMin;
        }
    }
    if (tempValue == 0) {
        return;
    }
    
    valueMin = (CGFloat) vMin;
    valueMax = (CGFloat) vMax;
    dataMax = dMax;
    graphHeight  = (int) self.bounds.size.height - yOffset * 2;
    graphCenter = graphHeight / 2;
    coefficient = ((CGFloat) graphCenter) - (yOffset * 2) / (CGFloat) (tempValue * 1.2);
    valueLimit = ((CGFloat) tempValue) * 1.2 * coefficient;
    valueRed = ((CGFloat) vMax) * coefficient;
    graphWidth = self.bounds.size.width;
    graphStepWidth = graphWidth / (CGFloat) dMax;
    if (graphStepWidth == 0 ){
        graphStepWidth = 1;
    }
    drawPoints = [NSMutableArray array];
    for (int i = 0; i < dMax; i++) {
        DPHitoeAccelerationData *initialize = [DPHitoeAccelerationData new];
        initialize.timeStamp =  0;
        initialize.accelX = -99999999.9;
        initialize.accelY = 0.0;
        initialize.accelZ = 0.0;
        [drawPoints addObject:initialize];
    }
    
    
    indexWriteNeed = 0;
    indexWritten = dMax;
    
    boundsRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    affine = CGAffineTransformIdentity;
    affine.d = -1.0;
    affine.ty = self.bounds.size.height;
    
    //***************************************************
    // 描画用ベース画像を用意する
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    // context 取得
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //***************************************************
    // 背景を塗りつぶす
    // 色
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    // バス作成
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddRect(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    // パス閉じる
    CGContextClosePath(context);
    // 描画
    CGContextFillPath(context);
    
    //***************************************************
    // ガイドなどの線を引く（準備）
    // 色
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    // 両端
    CGContextSetLineCap(context, kCGLineCapButt);
    // つなぎ目
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    // 太さ
    CGContextSetLineWidth(context, 1);
    
    
    //***************************************************
    // ガイドなどの線を引く（センター）
    // バス作成
    CGContextMoveToPoint(context, 0, (CGFloat) graphCenter);
    CGContextAddLineToPoint(context, graphWidth, (CGFloat) graphCenter);
    // パス閉じる
    CGContextClosePath(context);
    // 描画
    CGContextStrokePath(context);
    
    //***************************************************
    // ガイドなどの線を引く（スケール）
    yStart = (CGFloat) (graphCenter - (graphHeight / 2) - yOffset);
    yEnd = (CGFloat) (graphCenter + (graphHeight / 2) + yOffset);
    xInterval = (graphWidth / 6);
    // バス作成
    CGContextMoveToPoint(context, 0, yStart);
    CGContextAddLineToPoint(context, 0, yEnd);
    CGContextMoveToPoint(context, xInterval, yStart);
    CGContextAddLineToPoint(context, xInterval, yEnd);
    CGContextMoveToPoint(context, xInterval * 2, yStart);
    CGContextAddLineToPoint(context, xInterval * 2, yEnd);
    CGContextMoveToPoint(context, xInterval * 3, yStart);
    CGContextAddLineToPoint(context, xInterval * 3, yEnd);
    CGContextMoveToPoint(context, xInterval * 4, yStart);
    CGContextAddLineToPoint(context, xInterval * 4, yEnd);
    CGContextMoveToPoint(context, xInterval * 5, yStart);
    CGContextAddLineToPoint(context, xInterval * 5, yEnd);
    CGContextMoveToPoint(context, graphWidth, yStart);
    CGContextAddLineToPoint(context, graphWidth, yEnd);
    // パス閉じる
    CGContextClosePath(context);
    // 描画
    CGContextStrokePath(context);
    
    //***************************************************
    // UIImage取得
    imageBase = CGBitmapContextCreateImage(context);
    imagePrev = CGBitmapContextCreateImage(context);
    
    UIGraphicsEndImageContext();
    
    isReady = YES;
    
}
- (void)drawPointWithIndex:(int)index pulse:(DPHitoeAccelerationData *)pulse {
    if (!isReady) {
        return;
    }
    if (index < 0 || dataMax <= index) {
        return;
    }
    
    DPHitoeAccelerationData *accel = [DPHitoeAccelerationData new];
    accel.accelX = pulse.accelX;
    accel.accelY = pulse.accelY;
    accel.accelZ = pulse.accelZ;
    accel.timeStamp = index;
    drawPoints[index] = accel;
    
    indexWriteNeed = index;
}
- (void)drawPointNow {
    if (!isDrawActive) {
        isDrawActive = YES;
        [self setNeedsDisplay];
    }

}


#pragma mark - UIColor's const.

- (UIColor *)xColor
{
    return [UIColor redColor];
}

- (UIColor *)yColor
{
    return [UIColor greenColor];
}
- (UIColor *)zColor
{
    return [UIColor blueColor];
}

@end
