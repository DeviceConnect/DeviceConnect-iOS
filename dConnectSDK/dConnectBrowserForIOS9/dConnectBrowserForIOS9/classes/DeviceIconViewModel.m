//
//  DeviceIconViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
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
    NSString* target = [self targetBundle];
    NSString* bundle = [[NSBundle mainBundle] pathForResource:target ofType:@"bundle"];
    if (bundle) {
        NSString* imagePath = [NSString stringWithFormat:@"%@/dconnect_icon.png", bundle];
        return [[UIImage alloc] initWithContentsOfFile:imagePath];
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

//TODO: DConnectMessage.idからターゲットを判定する
- (NSString*)targetBundle
{
    NSArray* services = [[self idName] componentsSeparatedByString:@"."];
    NSString* target = [services objectAtIndex:1];
    if([target isEqualToString:@"DPPebbleDevicePlugin"]) {
        return @"dConnectDevicePebble";
    } else if([target isEqualToString:@"DPHostDevicePlugin"]) {
        return @"dConnectDeviceHost";
    } else if([target isEqualToString:@"DPThetaDevicePlugin"]) {
        return @"dConnectDeviceTheta";
    }

    return target;
}


- (void)dealloc
{
    self.message = nil;
}

@end
