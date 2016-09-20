//
//  DeviceIconViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DeviceIconViewModel.h"

@implementation DeviceIconViewModel

- (NSString*)name
{
    return (NSString*)[self.message arrayForKey: DConnectServiceDiscoveryProfileParamName];
}

- (BOOL)isOnline
{
    return [(NSNumber*)[self.message arrayForKey: DConnectServiceDiscoveryProfileParamOnline] boolValue];
}

- (NSString*)idName
{
    return (NSString*)[self.message arrayForKey: DConnectServiceDiscoveryProfileParamId];
}

- (NSString*)type
{
    return (NSString*)[self.message arrayForKey: DConnectServiceDiscoveryProfileParamType];
}

- (UIImage*)iconImage
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    NSString* filePath = [mgr iconFilePathForServiceId:[self idName] isOnline:self.isOnline];
    if (filePath) {
        return [[UIImage alloc] initWithContentsOfFile:filePath];
    } else {
        NSString* filename = self.isOnline ? @"default_device_icon" : @"default_device_icon_off";
        return [UIImage imageNamed:filename];
    }
}

- (NSString*)typeIconFilename
{
    NSString* type = (NSString*)[self.message arrayForKey: @"type"];
    if ([type isEqualToString:DConnectServiceDiscoveryProfileNetworkTypeWiFi]) {
        return self.isOnline ? @"wifi_on" : @"wifi_off";
    } else if ([type isEqualToString:DConnectServiceDiscoveryProfileNetworkTypeBluetooth] ||
               [type isEqualToString:DConnectServiceDiscoveryProfileNetworkTypeBLE]) {
        return self.isOnline ? @"bluetooth_on" : @"bluetooth_off";
    } else if ([type isEqualToString:DConnectServiceDiscoveryProfileNetworkTypeNFC]) {
        return self.isOnline ? @"nfc_on" : @"nfc_off";
    } else {
        //NOTE: Unknown or type not exist
        return nil;
    }
}

- (void)dealloc
{
    self.message = nil;
}

@end
