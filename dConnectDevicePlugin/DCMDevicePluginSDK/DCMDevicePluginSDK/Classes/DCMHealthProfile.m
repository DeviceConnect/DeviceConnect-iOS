//
//  DCMHealthProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMHealthProfile.h"


NSString *const DCMHealthProfileName = @"health";
NSString *const DCMHealthProfileAttrHeart = @"heart";
NSString *const DCMHealthProfileParamHeart = @"heart";
NSString *const DCMHealthProfileParamRate = @"rate";
NSString *const DCMHealthProfileParamValue = @"value";
NSString *const DCMHealthProfileParamMDERFloat = @"mderFloat";
NSString *const DCMHealthProfileParamType = @"type";
NSString *const DCMHealthProfileParamTypeCode = @"typeCode";
NSString *const DCMHealthProfileParamUnit = @"unit";
NSString *const DCMHealthProfileParamUnitCode = @"unitCode";
NSString *const DCMHealthProfileParamTimeStamp = @"timeStamp";
NSString *const DCMHealthProfileParamTimeStampString = @"timeStampString";
NSString *const DCMHealthProfileParamRR = @"rr";
NSString *const DCMHealthProfileParamEnergy = @"energy";
NSString *const DCMHealthProfileParamDevice = @"device";
NSString *const DCMHealthProfileParamProductName = @"productName";
NSString *const DCMHealthProfileParamManufacturerName = @"manufacturerName";
NSString *const DCMHealthProfileParamModelNumber = @"modelNumber";
NSString *const DCMHealthProfileParamFirmwareRevision = @"firmwareRevision";
NSString *const DCMHealthProfileParamSerialNumber = @"serialNumber";
NSString *const DCMHealthProfileParamSoftwareRevision = @"softwareRevision";
NSString *const DCMHealthProfileParamHardwareRevision = @"hardwareRevision";
NSString *const DCMHealthProfileParamPartNumber = @"partNumber";
NSString *const DCMHealthProfileParamProtocolRevision = @"protocolRevision";
NSString *const DCMHealthProfileParamSystemId = @"systemId";
NSString *const DCMHealthProfileParamBatteryLevel = @"batteryLevel";

@implementation DCMHealthProfile

- (NSString *) profileName {
    return DCMHealthProfileName;
}

#pragma mark - Setter
+ (void) setHeart:(DConnectMessage *)heart target:(DConnectMessage *)message {
    [message setMessage:heart forKey:DCMHealthProfileParamHeart];
}
+ (void) setRate:(DConnectMessage *)rate target:(DConnectMessage *)message {
    [message setMessage:rate forKey:DCMHealthProfileParamRate];
}
+ (void) setRRI:(DConnectMessage *)rr target:(DConnectMessage *)message {
    [message setMessage:rr forKey:DCMHealthProfileParamRR];
}
+ (void) setEnergyExtended:(DConnectMessage *)energy target:(DConnectMessage *)message {
    [message setMessage:energy forKey:DCMHealthProfileParamEnergy];
}
+ (void) setDevice:(DConnectMessage *)device target:(DConnectMessage *)message {
    [message setMessage:device forKey:DCMHealthProfileParamDevice];
}
+ (void) setValue:(double)value target:(DConnectMessage *)message {
    [message setDouble:value forKey:DCMHealthProfileParamValue];
}
+ (void) setMDERFloat:(NSString*)mderFloat target:(DConnectMessage *)message {
    [message setString:mderFloat forKey:DCMHealthProfileParamMDERFloat];
}
+ (void) setType:(NSString*)type target:(DConnectMessage *)message {
    [message setString:type forKey:DCMHealthProfileParamType];
}
+ (void) setTypeCode:(int)typeCode target:(DConnectMessage *)message {
    [message setInteger:typeCode forKey:DCMHealthProfileParamTypeCode];
}
+ (void) setUnit:(NSString*)unit target:(DConnectMessage *)message {
    [message setString:unit forKey:DCMHealthProfileParamUnit];
}
+ (void) setUnitCode:(int)unitCode target:(DConnectMessage *)message {
    [message setInteger:unitCode forKey:DCMHealthProfileParamUnitCode];
}
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMHealthProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMHealthProfileParamTimeStampString];
}
+ (void) setProductName:(NSString*)productName target:(DConnectMessage *)message {
    [message setString:productName forKey:DCMHealthProfileParamProductName];
}
+ (void) setManufacturerName:(NSString*)manufacturerName target:(DConnectMessage *)message {
    [message setString:manufacturerName forKey:DCMHealthProfileParamManufacturerName];
}
+ (void) setModelNumber:(NSString*)modelNumber target:(DConnectMessage *)message {
    [message setString:modelNumber forKey:DCMHealthProfileParamModelNumber];
}
+ (void) setFirmwareRevision:(NSString*)firmwareRevision target:(DConnectMessage *)message {
    [message setString:firmwareRevision forKey:DCMHealthProfileParamFirmwareRevision];
}
+ (void) setSerialNumber:(NSString*)serialNumber target:(DConnectMessage *)message {
    [message setString:serialNumber forKey:DCMHealthProfileParamSerialNumber];
}
+ (void) setSoftwareRevision:(NSString*)softwareRevision target:(DConnectMessage *)message {
    [message setString:softwareRevision forKey:DCMHealthProfileParamSoftwareRevision];
}
+ (void) setHardwareRevision:(NSString*)hardwareRevision target:(DConnectMessage *)message {
    [message setString:hardwareRevision forKey:DCMHealthProfileParamHardwareRevision];
}
+ (void) setProtocolRevision:(NSString*)protocolRevision target:(DConnectMessage *)message {
    [message setString:protocolRevision forKey:DCMHealthProfileParamProtocolRevision];
}
+ (void) setPartNumber:(NSString*)partNumber target:(DConnectMessage *)message {
    [message setString:partNumber forKey:DCMHealthProfileParamPartNumber];
}
+ (void) setSystemId:(NSString*)systemId target:(DConnectMessage *)message {
    [message setString:systemId forKey:DCMHealthProfileParamSystemId];
}
+ (void) setBatteryLevel:(double)batteryLevel target:(DConnectMessage *)message {
    [message setDouble:batteryLevel forKey:DCMHealthProfileParamBatteryLevel];
}


@end
