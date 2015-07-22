//
//  DPAllJoynServiceEntity.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynServiceEntity.h"


static NSString *const DPAllJoynAboutDataException =
@"DPAllJoynAboutDataException";


@implementation DPAllJoynServiceEntity

- (instancetype) initWithBusName:(NSString *)busName
                            port:(AJNSessionPort)port
                       aboutData:(AJNMessageArgument *)aboutData
                    proxyObjects:(AJNMessageArgument *)proxyObjects
{
    if (!busName) {
        NSLog(@"%s: busName can not be nil.", __PRETTY_FUNCTION__);
        return nil;
    }
    if (!proxyObjects) {
        NSLog(@"%s: proxyObjects can not be nil.", __PRETTY_FUNCTION__);
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.busName = busName;
        self.port = port;
        self.aboutData = aboutData;
        self.proxyObjects = proxyObjects;
        
        [self flattenAboutData];
        
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
        NSLog(@"Failed to parse about data.");
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
            NSLog(@"Failed to obtain a value.");
            continue;
        }
        key = @(keyCStr);
        
        @try {
            if ([key isEqualToString:@"AppId"]) {
                size_t length;
                uint8_t *appId;
                status = val->Get("ay", &length, &appId);
                if (ER_OK != status) {
                    NSLog(@"Failed to obtain a string value. About key: %@.", key);
                } else {
                    _appId = [NSData dataWithBytes:appId
                                            length:length];
//                    _appId = appId;
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
                    NSLog(@"Failed to obtain a string value. About key: %@.", key);
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
            NSLog(@"%@. About key: %@.", ex.reason, key);
        }
    }
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

@end
