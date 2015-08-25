//
//  DPThetaOmnidirectionalImage.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/20.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DPThetaOmnidirectionalImage : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSString *mimeType;
@property NSString *uri;
@property NSData *image;

typedef void (^DPOmniBlock)();


- (instancetype)initWithURL:(NSURL*)url origin:(NSString*)origin callback:(DPOmniBlock)callback;
@end
