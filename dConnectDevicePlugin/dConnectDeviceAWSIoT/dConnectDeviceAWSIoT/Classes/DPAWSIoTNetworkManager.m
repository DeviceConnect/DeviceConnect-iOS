//
//  DPAWSIoTNetworkManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTNetworkManager.h"

@interface DPAWSIoTNetworkManager () {
}
@end

@implementation DPAWSIoTNetworkManager

// Query作成
+ (NSURLComponents*)buildQuery:(NSString*)path params:(NSDictionary*)params {
	NSURLComponents *components = [NSURLComponents componentsWithString:path];
	NSMutableArray *array = [NSMutableArray array];
	for (NSString *key in params.allKeys) {
		NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:params[key]];
		[array addObject:item];
	}
	[components setQueryItems:array];
	return components;
}

// HTTP通信
+ (void)sendRequestWithPath:(NSString*)path method:(NSString*)method
					 params:(NSDictionary*)params headers:(NSDictionary*)headers
					handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler {

	NSString *methodStr = [method uppercaseString];
	BOOL needsQuery = ([methodStr isEqualToString:@"GET"] || [methodStr isEqualToString:@"DELETE"]);
	
	NSURLComponents *components = [self buildQuery:path params:params];
	NSURL *url;
	if (needsQuery) {
		url = components.URL;
	} else {
		url = [NSURL URLWithString:path];
	}
	
	NSURLSession *session = [NSURLSession sharedSession];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.HTTPMethod = methodStr;
	if (!needsQuery) {
		request.HTTPBody = [components.query dataUsingEncoding:NSUTF8StringEncoding];
	}
	[request setAllHTTPHeaderFields:headers];
	
	[[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (handler) {
				handler(data, response, error);
			}
		});

	}] resume];
}

+ (void)sendRequest:(NSURLRequest *)request
            handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(data, response, error);
        }
    }] resume];
}

@end
