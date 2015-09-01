//
//  DPThetaRoiDeliveryContext.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "DPThetaROI.h"
#import "DPThetaOmnidirectionalImage.h"
@protocol DPThetaRoiDeliveryContextDelegate<NSObject>
-(void)didUpdateMediaWithSegment:(NSString*)segment data:(NSData *)data;
-(void)didExpiredMediaWithSegment:(NSString*)segment;
@end
@interface DPThetaRoiDeliveryContext : NSObject

/*!
 @brief DPThetaRoiDeliveryContextのデリゲートオブジェクト。
 
 デリゲートは @link DPThetaRoiDeliveryContextDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, assign) id<DPThetaRoiDeliveryContextDelegate> delegate;
@property (nonatomic) NSString *segment;
@property (nonatomic) NSData *roi;
@property (nonatomic) NSURL *uri;
@property (nonatomic) DPThetaParam *currentParam;


- (instancetype)initWithSource:(DPThetaOmnidirectionalImage *)source callback:(void(^)())callback;

- (void)render;
- (void)draw;
- (void)changeRenderParameter:(DPThetaParam *)parameter isUserRequest:(BOOL)isUserRequest;
- (void)destroy;
- (void)removeGLView;

- (void)startExpiredTimer;
- (void)stopExpiredTimer;
- (void)restartExpiredTimer;
@end
