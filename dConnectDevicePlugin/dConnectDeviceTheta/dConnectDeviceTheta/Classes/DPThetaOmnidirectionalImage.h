//
//  DPThetaOmnidirectionalImage.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
