//
//  DPHitoeDeviceData.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeTargetDeviceData.h"
#import <DCMDevicePluginSDK/DCMHealthProfile.h>

@implementation DPHitoeTargetDeviceData

- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    [DCMHealthProfile setProductName:self.productName target:message];
    [DCMHealthProfile setManufacturerName:self.manufacturerName target:message];
    [DCMHealthProfile setModelNumber:self.modelNumber target:message];
    [DCMHealthProfile setFirmwareRevision:self.firmwareRevision target:message];
    [DCMHealthProfile setSerialNumber:self.serialNumber target:message];
    [DCMHealthProfile setSoftwareRevision:self.softwareRevision target:message];
    [DCMHealthProfile setHardwareRevision:self.hardwareRevision target:message];
    [DCMHealthProfile setProtocolRevision:self.protocolRevision target:message];
    [DCMHealthProfile setPartNumber:self.partNumber target:message];
    [DCMHealthProfile setSystemId:self.systemId target:message];
    [DCMHealthProfile setBatteryLevel:self.batteryLevel target:message];
    return message;
}
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
@end
