//
//  DConnectConnectionProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectConnectionProfile.h"

// Profile Name
NSString *const DConnectConnectionProfileName = @"connection";

// Attribute
NSString *const DConnectConnectionProfileAttrWifi              = @"wifi";
NSString *const DConnectConnectionProfileAttrBluetooth         = @"bluetooth";
NSString *const DConnectConnectionProfileAttrDiscoverable      = @"discoverable";
NSString *const DConnectConnectionProfileAttrBLE               = @"ble";
NSString *const DConnectConnectionProfileAttrNFC               = @"nfc";
NSString *const DConnectConnectionProfileAttrOnWifiChange      = @"onwifichange";
NSString *const DConnectConnectionProfileAttrOnBluetoothChange = @"onbluetoothchange";
NSString *const DConnectConnectionProfileAttrOnBLEChange       = @"onblechange";
NSString *const DConnectConnectionProfileAttrOnNFCChange       = @"onnfcchange";

// Parameter
NSString *const DConnectConnectionProfileParamEnable        = @"enable";
NSString *const DConnectConnectionProfileParamConnectStatus = @"connectStatus";

// Interface
NSString *const DConnectConnectionProfileInterfaceBluetooth = @"bluetooth";

@implementation DConnectConnectionProfile

#pragma mark - DConnectionProfile Methods

- (NSString *) profileName {
    return DConnectConnectionProfileName;
}

#pragma mark - Setter

+ (void) setEnable:(BOOL)enable target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Message must not be nil.";
    } else {
        [message setBool:enable forKey:DConnectConnectionProfileParamEnable];
    }
}

+ (void) setConnectStatus:(DConnectMessage *)connectStatus target:(DConnectMessage *)message {
    if (!connectStatus) {
        @throw @"ConnectStatus must not be nil.";
    } else if (!message) {
        @throw @"Message must not be nil.";
    } else {
        [message setMessage:connectStatus forKey:DConnectConnectionProfileParamConnectStatus];
    }
}

@end
