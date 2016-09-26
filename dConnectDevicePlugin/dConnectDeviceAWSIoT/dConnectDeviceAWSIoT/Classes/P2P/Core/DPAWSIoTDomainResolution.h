//
//  DPAWSIoTDomainResolution.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^HostResolutaionCallback)(int, NSString*);

@interface DPAWSIoTDomainResolution : NSObject

- (void) resolveHostName:(NSString *)hostName callback:(HostResolutaionCallback)callback;

@end
