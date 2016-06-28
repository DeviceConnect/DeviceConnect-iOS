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

@interface DConnectConnectProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectConnectProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectConnectProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (!attribute) {
        [response setErrorToNotSupportProfile];
    }
    else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrWifi] == NSOrderedSame) {
        if ([self hasMethod:@selector(profile:didReceiveGetWifiRequest:response:serviceId:) response:response])
        {
            send = [_delegate profile:self didReceiveGetWifiRequest:request
                             response:response serviceId:serviceId];
        }
    } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrBluetooth] == NSOrderedSame) {
        if ([self hasMethod:@selector(profile:didReceiveGetBluetoothRequest:response:serviceId:) response:response])
        {
            send = [_delegate profile:self didReceiveGetBluetoothRequest:request
                             response:response serviceId:serviceId];
        }
    } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrNFC] == NSOrderedSame) {
        if ([self hasMethod:@selector(profile:didReceiveGetNFCRequest:response:serviceId:) response:response])
        {
            send = [_delegate profile:self didReceiveGetNFCRequest:request
                             response:response serviceId:serviceId];
        }
    } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrBLE] == NSOrderedSame) {
        if ([self hasMethod:@selector(profile:didReceiveGetBLERequest:response:serviceId:) response:response])
        {
            send = [_delegate profile:self didReceiveGetBLERequest:request
                             response:response serviceId:serviceId];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (!interface) {
        if (attribute) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrWifi] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutWiFiRequest:response:serviceId:) response:response])
                {
                    send = [_delegate profile:self didReceivePutWiFiRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrBluetooth] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutBluetoothRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutBluetoothRequest:request
                                     response:response serviceId:serviceId];
                }
                
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrNFC] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutNFCRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutNFCRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrBLE] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutBLERequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutBLERequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrOnWifiChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:
                                              didReceivePutOnWifiChangeRequest:
                                              response:
                                              serviceId:
                                              sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutOnWifiChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrOnBluetoothChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutOnBluetoothChangeRequest:
                                              response:
                                              serviceId:
                                              sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutOnBluetoothChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrOnNFCChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutOnNFCChangeRequest:response:serviceId:sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutOnNFCChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrOnBLEChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceivePutOnBLEChangeRequest:response:serviceId:sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceivePutOnBLEChangeRequest:request response:response
                                     serviceId:serviceId sessionKey:sessionKey];
                }
            } else {
                [response setErrorToNotSupportProfile];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if (interface && [interface localizedCaseInsensitiveCompare: DConnectConnectProfileInterfaceBluetooth] == NSOrderedSame
               && attribute && [attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrDiscoverable] == NSOrderedSame)
    {
        if ([self hasMethod:@selector(profile:didReceivePutBluetoothDiscoverableRequest:response:serviceId:)
            response:response])
        {
            send = [_delegate profile:self didReceivePutBluetoothDiscoverableRequest:request
                             response:response serviceId:[request serviceId]];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (!interface) {
        if (attribute) {
            
            NSString *sessionKey = [request sessionKey];
            
            if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrWifi] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteWiFiRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteWiFiRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrBluetooth] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteBluetoothRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteBluetoothRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrNFC] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteNFCRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteNFCRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrBLE] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteBLERequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteBLERequest:request
                                     response:response serviceId:serviceId];
                }
                
            } else if ([attribute localizedCaseInsensitiveCompare: DConnectConnectProfileAttrOnWifiChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:
                                              didReceiveDeleteOnWifiChangeRequest:
                                              response:
                                              serviceId:
                                              sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteOnWifiChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrOnBluetoothChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:
                                              didReceiveDeleteOnBluetoothChangeRequest:
                                              response:
                                              serviceId:
                                              sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteOnBluetoothChangeRequest:request
                                     response:response serviceId:serviceId
                                   sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrOnNFCChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteOnNFCChangeRequest:response:serviceId:sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteOnNFCChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else if ([attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrOnBLEChange] == NSOrderedSame) {
                if ([self hasMethod:@selector(profile:didReceiveDeleteOnBLEChangeRequest:response:serviceId:sessionKey:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveDeleteOnBLEChangeRequest:request
                                     response:response serviceId:serviceId sessionKey:sessionKey];
                }
            } else {
                [response setErrorToNotSupportProfile];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if (interface && [interface localizedCaseInsensitiveCompare:DConnectConnectProfileInterfaceBluetooth] == NSOrderedSame
               && attribute && [attribute localizedCaseInsensitiveCompare:DConnectConnectProfileAttrDiscoverable] == NSOrderedSame)
    {
        if ([self hasMethod:@selector(profile:didReceiveDeleteBluetoothDiscoverableRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteBluetoothDiscoverableRequest:request
                             response:response serviceId:serviceId];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
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

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
