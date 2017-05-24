/**
 * @file  SampleDeviceDiscovery.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "UdpRequest.h"

@protocol SampleDeviceDiscoveryDelegate

- (void)didReceiveDeviceList:(BOOL)isReceived;

@end

@interface SampleDeviceDiscovery
    : NSObject <UdpRequestDelegate, NSXMLParserDelegate>

- (void)discover:(id<SampleDeviceDiscoveryDelegate>)delegate;

@end
