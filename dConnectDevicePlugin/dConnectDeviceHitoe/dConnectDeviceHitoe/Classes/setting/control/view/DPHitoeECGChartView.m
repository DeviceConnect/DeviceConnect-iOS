//
//  ECGChartView.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeECGChartView.h"
#import <CoreGraphics/CoreGraphics.h>

static int const DPHitoePluseDensityCount = 20;
// データ数
static int const DPHitoeDataCount = 1;
// データタイトル
static NSString *const DPHitoeTitle = @"ECG";

@interface DPHitoeECGChartView() {
    CGFloat graphWidth;
    int graphHeight;
    int interval;
    int graphCenter;
    CGFloat coefficient;
    NSMutableArray *drawPoints;
    int dataMax;
    CGFloat graphStepWidth;
    BOOL drawGuide;
    CGFloat yOffset;
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
    CGFloat prevPoint;

    CGImageRef imageBase;
    CGImageRef imagePrev;

    CGRect boundsRect;
    CGAffineTransform affine;

    BOOL isDrawActive;
}

@end
@implementation DPHitoeECGChartView

- (instancetype)init {
    self = [super init];
    if (self) {
        drawPoints = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int indexStart = 0;
    
    if (indexWritten == indexWriteNeed) {
        isDrawActive = NO;
        return;
    } else if (indexWritten < indexWriteNeed) {
        // 正常パターン
        // 未描画分を全部描画する，indexWritten から indexWriteNeed まで
        if (imagePrev) {
            CGContextConcatCTM(context, affine);
            CGContextDrawImage(context, boundsRect, imagePrev);
        }
        
        indexStart = indexWritten;
    } else {
        // インデックスが戻った（主に br == 0）
        // 先頭（index:0）から indexWriteNeed まで描画する
        if (imageBase) {
            CGContextConcatCTM(context, affine);
            CGContextDrawImage(context, boundsRect, imageBase);
            imagePrev = nil;
            imagePrev = CGBitmapContextCreateImage(context);
        }
        indexStart = 0;
        
    }
    
    CGContextSetStrokeColorWithColor(context, [self dataColor].CGColor);
    
    BOOL isFirst = YES;
    for (indexWritten = indexStart; indexWritten <= indexWriteNeed; indexWritten++) {
        CGFloat point = 0;
        if ([drawPoints[indexWritten] doubleValue] != -99999999.9) {
            point = [drawPoints[indexWritten] doubleValue] * coefficient;
        } else {
            continue;
        }
        
        point += (CGFloat) graphCenter;
        if (point < yStart) {
            point = yStart;
        } else if (yEnd < point) {
            point = yEnd;
        }
        
        if (isFirst) {
            isFirst = NO;
            if (indexStart == 0) {
                CGFloat pointPrev = (CGFloat) graphCenter;
                CGContextMoveToPoint(context, 0, pointPrev);
            } else {
                CGContextMoveToPoint(context,  prevStepIndex * graphStepWidth, prevPoint);
            }
        }
        CGContextAddLineToPoint(context, indexWritten * graphStepWidth, point);
        
        prevStepIndex = indexWritten;
        prevPoint = point;
    }
    
    CGContextStrokePath(context);
    imagePrev = nil;
    imagePrev = CGBitmapContextCreateImage(context);
    
    isDrawActive = NO;
    
    UIGraphicsEndImageContext();
}

#pragma mark - Public method
- (void)setupWithDataMax:(int)dMax valueMin:(double)vMin valueMax:(double)vMax {
    isReady = NO;
    coefficient = 1.0;
    indexWritten = 0;
    CGFloat tempValue = 0.0;
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
    graphHeight  = ((int) self.bounds.size.height) - (yOffset * 2);
    graphCenter = graphHeight / 2;
    coefficient = ((CGFloat) graphCenter) - (yOffset * 2) / (((CGFloat) tempValue) * 1.2);
    valueLimit = ((CGFloat) tempValue) * 1.2 * coefficient;
    valueRed = ((CGFloat) valueMax) * coefficient;
    graphWidth = self.bounds.size.width;
    graphStepWidth = graphWidth / ((CGFloat) dMax);
    if (graphStepWidth == 0) {
        graphStepWidth = 1;
    }
    NSNumber *initialize[dMax];
    for (int i = 0; i < dMax; i++) {
        initialize[i] = @(-99999999.9);
    }
    drawPoints = [NSMutableArray arrayWithObjects:initialize count:dMax];//[NSMutableArray arrayWithObjects:obj count:dataMax];
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
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
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
    CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
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


-(void)drawPointWithIndex:(int)index pulse:(double)pulse {
    if (!isReady) {
        return;
    }
    if (index < 0 || dataMax <= index) {
        return;
    }
    drawPoints[index] = @((CGFloat) pulse);
    indexWriteNeed = index;
}

- (void)drawPointNow {
    if (!isDrawActive) {
        isDrawActive = YES;
        [self setNeedsDisplay];
    }
}
#pragma mark - UIColor's const.

- (UIColor *)dataColor
{
    return [UIColor greenColor];
}


@end
