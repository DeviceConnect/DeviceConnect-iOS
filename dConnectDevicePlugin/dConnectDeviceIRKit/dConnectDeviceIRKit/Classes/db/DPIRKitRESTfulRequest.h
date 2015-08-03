//
//  DPIRKitRESTfulRequest.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPIRKitRESTfulRequest : NSObject

@property (nonatomic, copy) NSString *index;
@property (nonatomic, copy) NSString *ir;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *profile;

@end
