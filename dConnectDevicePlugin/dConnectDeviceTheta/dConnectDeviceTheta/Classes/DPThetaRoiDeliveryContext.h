//
//  DPThetaRoiDeliveryContext.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/21.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "DPThetaROI.h"
#import "DPThetaOmnidirectionalImage.h"
@protocol DPThetaRoiDeliveryContextDelegate<NSObject>
-(void)didUpdateMediaWithSegment:(NSString*)segment data:(NSData *)data;
@end
@interface DPThetaRoiDeliveryContext : NSObject
{
    dispatch_source_t _timerSource;
}


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

@end
