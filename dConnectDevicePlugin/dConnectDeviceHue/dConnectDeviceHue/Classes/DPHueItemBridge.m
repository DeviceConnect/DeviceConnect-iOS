//
//  DPHueItemBridge.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueItemBridge.h"

@implementation DPHueItemBridge
- (id)copyWithZone:(NSZone *)zone
{
    DPHueItemBridge *copiedObject = [[[self class] allocWithZone:zone] init];
    if (copiedObject) {
        copiedObject->_bridgeId = [_bridgeId copyWithZone:zone];
        copiedObject->_ipAddress = [_ipAddress copyWithZone:zone];
    }
    return copiedObject;
}
@end
