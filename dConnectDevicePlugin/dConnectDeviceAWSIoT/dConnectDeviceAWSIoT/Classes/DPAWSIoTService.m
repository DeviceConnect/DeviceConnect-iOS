//
//  DPAWSIoTService.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPAWSIoTService.h"

@implementation DPAWSIoTService

- (instancetype) initWithServiceId:(NSString *)serviceId deviceName: (NSString *) deviceName plugin: (id) plugin {
	self = [super initWithServiceId: serviceId plugin: plugin dataSource: self];
	if (self) {
		[self setName: deviceName];
		[self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
		[self setOnline: YES];
	}
	return self;
}

@end
