/**
 * @file  DeviceInfo.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

@interface DeviceInfo : NSObject

- (void)setFriendlyName:(NSString *)friendlyName;

- (NSString *)getFriendlyName;

- (void)setVersion:(NSString *)version;

- (NSString *)getVersion;

- (void)addService:(NSString *)serviceName serviceUrl:(NSString *)serviceUrl;

- (NSString *)findActionListUrl:(NSString *)service;

@end
