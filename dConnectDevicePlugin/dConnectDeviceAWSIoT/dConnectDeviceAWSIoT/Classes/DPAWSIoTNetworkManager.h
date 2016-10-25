//
//  DPAWSIoTNetworkManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPAWSIoTNetworkManager : NSObject

// HTTP通信
+ (void)sendRequestWithPath:(NSString*)path method:(NSString*)method
					 params:(NSDictionary*)params headers:(NSDictionary*)headers
					handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler;

+ (void)sendRequest:(NSURLRequest *)request
            handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler;

@end
