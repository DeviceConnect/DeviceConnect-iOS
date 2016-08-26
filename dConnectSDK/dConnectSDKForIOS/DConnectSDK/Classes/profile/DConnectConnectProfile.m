//
//  DConnectConnectProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectConnectProfile.h"

// Profile Name
NSString *const DConnectConnectProfileName = @"connect";

// Attribute
NSString *const DConnectConnectProfileAttrWifi              = @"wifi";
NSString *const DConnectConnectProfileAttrBluetooth         = @"bluetooth";
NSString *const DConnectConnectProfileAttrDiscoverable      = @"discoverable";
NSString *const DConnectConnectProfileAttrBLE               = @"ble";
NSString *const DConnectConnectProfileAttrNFC               = @"nfc";
NSString *const DConnectConnectProfileAttrOnWifiChange      = @"onwifichange";
NSString *const DConnectConnectProfileAttrOnBluetoothChange = @"onbluetoothchange";
NSString *const DConnectConnectProfileAttrOnBLEChange       = @"onblechange";
NSString *const DConnectConnectProfileAttrOnNFCChange       = @"onnfcchange";

// Parameter
NSString *const DConnectConnectProfileParamEnable        = @"enable";
NSString *const DConnectConnectProfileParamConnectStatus = @"connectStatus";

// Interface
NSString *const DConnectConnectProfileInterfaceBluetooth = @"bluetooth";

@implementation DConnectConnectProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectConnectProfileName;
}

#pragma mark - Setter

+ (void) setEnable:(BOOL)enable target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Message must not be nil.";
    } else {
        [message setBool:enable forKey:DConnectConnectProfileParamEnable];
    }
}

+ (void) setConnectStatus:(DConnectMessage *)connectStatus target:(DConnectMessage *)message {
    if (!connectStatus) {
        @throw @"ConnectStatus must not be nil.";
    } else if (!message) {
        @throw @"Message must not be nil.";
    } else {
        [message setMessage:connectStatus forKey:DConnectConnectProfileParamConnectStatus];
    }
}

@end
