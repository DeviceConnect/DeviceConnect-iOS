//
//  DPAllJoynServiceEntity.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynServiceEntity.h"

#import <AllJoynFramework_iOS.h>


static NSString *const DPAllJoynAboutDataException =
@"DPAllJoynAboutDataException";


@implementation DPAllJoynServiceEntity

- (instancetype) initWithBusName:(NSString *)busName
                            port:(AJNSessionPort)port
                       aboutData:(AJNMessageArgument *)aboutData
           busObjectDescriptions:(AJNMessageArgument *)busObjectDescriptionArg
{
    if (!busName) {
        DCLogError(@"busName can not be nil.");
        return nil;
    }
    if (!busObjectDescriptionArg) {
        DCLogError(@"busObjectDescriptionArg can not be nil.");
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.busName = busName;
        self.port = port;
        self.aboutData = aboutData;
        self.busObjectDescriptionArg = busObjectDescriptionArg;
        self.lastAlive = [NSDate date];
        
        [self flattenAboutData];
        self.busObjectDescriptions = [self remapProxyObjectsToDictionary];
        
        [self determineServiceName];
    }
    return self;
}

/*!
 * Flatten <code>aboutData</code> to member properties.
 */
- (void) flattenAboutData
{
    // Assume the signatures of aboutData and its entries conform to the
    // About service interface definition.
    // https://allseenalliance.org/developers/learn/core/about-announcement/interface
    //
    // TODO: signature validity check
    // Use MsgArg#Signature() for this purpose.
    
    if (!_aboutData) {
        return;
    }
    
    QStatus status;
    size_t size;
    MsgArg *entries;
    status = [_aboutData value:@"a{sv}", &size, &entries];
    
    if (ER_OK != status) {
        DCLogError(@"Failed to parse about data.");
        return;
    }
    if (size == 0) {
        return;
    }
    
    for (size_t i = 0; i < size; ++i) {
        char *keyCStr;
        MsgArg *val;
        NSString *key;
        status = entries[i].Get("{sv}", &keyCStr, &val);
        if (ER_OK != status) {
            DCLogError(@"Failed to obtain a value.");
            continue;
        }
        key = @(keyCStr);
        
        @try {
            if ([key isEqualToString:@"AppId"]) {
                size_t length;
                uint8_t *appId;
                status = val->Get("ay", &length, &appId);
                if (ER_OK != status) {
                    DCLogError(@"Failed to obtain a byte array. About key: %@.", key);
                } else {
                    _appId =
                    [DPAllJoynServiceEntity hexadecimalStringWithData:
                     [NSData dataWithBytes:appId length:length]];
                }
            } else if ([key isEqualToString:@"DefaultLanguage"]) {
                ////             If default language is not specified, set it to English.
                _defaultLanguage = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"DeviceName"]) {
                _deviceName = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"DeviceId"]) {
                _deviceId = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"AppName"]) {
                _appName = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"Manufacturer"]) {
                _manufacturer = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"ModelNumber"]) {
                _modelNumber = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"SupportedLanguages"]) {
                size_t length;
                char **supportedLanguages;
                QStatus status = val->Get("as", &length, &supportedLanguages);
                if (ER_OK != status) {
                    DCLogError(@"Failed to obtain a string value. About key: %@.", key);
                } else {
                    if (length == 0) {
                        continue;
                    }
                    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:length];
                    for (size_t j = 0; j < length; j++) {
                        [tmp addObject:@(supportedLanguages[j])];
                    }
                    _supportedLanguages = tmp;
                }
            } else if ([key isEqualToString:@"Description"]) {
                _aboutDescription = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"DateOfManufacture"]) {
                _dateOfManufacture = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"SoftwareVersion"]) {
                _softwareVersion = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"AJSoftwareVersion"]) {
                _ajSoftwareVersion = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"HardwareVersion"]) {
                _hardwareVersion = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            } else if ([key isEqualToString:@"SupportUrl"]) {
                _supportUrl = [DPAllJoynServiceEntity stringValueFromMsgArg:val];
            }
        }
        @catch (NSException *ex) {
            DCLogError(@"%@. About key: %@.", ex.reason, key);
        }
    }
}


- (NSDictionary *)remapProxyObjectsToDictionary
{
    QStatus status;
    NSMutableDictionary *dict;
    size_t size1;
    MsgArg *entries1;
    status = [_busObjectDescriptionArg value:@"a(oas)", &size1, &entries1];
    if (ER_OK != status) {
        DCLogError(@"Failed to parse bus object descriptions.");
        return nil;
    }
    dict = [NSMutableDictionary dictionaryWithCapacity:size1];
    for (size_t i = 0; i < size1; ++i) {
        char *objPath;
        NSMutableArray *ifaces;
        size_t size2;
        MsgArg *entries2;
        status = entries1[i].Get("(oas)", &objPath, &size2, &entries2);
        if (ER_OK != status) {
            DCLogError(@"Failed to parse a bus object description. Skipping it...");
            continue;
        }
        ifaces = [NSMutableArray arrayWithCapacity:size2];
        for (size_t j = 0; j < size2; ++j) {
            char *iface;
            status = entries2[j].Get("s", &iface);
            if (ER_OK != status) {
                DCLogError(@"Failed to parse a supported interface in a bus object"
                           " description. Skipping it...");
                continue;
            }
            [ifaces addObject:@(iface)];
        }
        dict[@(objPath)] = ifaces;
    }
    
    return dict;
}


+ (NSString *)stringValueFromMsgArg:(MsgArg *)msgArg
{
    char *valCStr;
    QStatus status = msgArg->Get("s", &valCStr);
    if (ER_OK != status) {
        [NSException raise:DPAllJoynAboutDataException
                    format:@"Failed to obtain a string value."];
    }
    return @(valCStr);
}


/**
 * Determine a DeviceConnect service name.
 */
- (void) determineServiceName
{
    if (_deviceName) {
        _serviceName = _deviceName;
    } else {
        _serviceName =
        [NSString stringWithFormat:@"Alljoyn service (%d)", _busName.hash];
    }
}

+ (NSString *)hexadecimalStringWithData:(NSData *)data
{
    const unsigned char *bytes = (const unsigned char *)data.bytes;
    
    if (!bytes) {
        return nil;
    }
    
    NSUInteger dataLength = data.length;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:dataLength * 2];
    
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", (unsigned int)bytes[i]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
