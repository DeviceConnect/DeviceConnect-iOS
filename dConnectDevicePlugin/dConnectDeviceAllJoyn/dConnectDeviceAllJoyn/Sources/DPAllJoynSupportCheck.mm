//
//  DPAllJoynSupportCheck.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSupportCheck.h"

#import <AllJoynFramework_iOS.h>
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>
#import "DPAllJoynConst.h"
#import "NSArray+Query.h"


@implementation DPAllJoynSupportCheck

+ (NSSet *)allInterfaceNamesFromBusObjectDescriptions:
(AJNMessageArgument *)busObjectDescriptions
{
    NSMutableSet *interfaces = [NSMutableSet new];
    
    QStatus status;
    size_t size;
    MsgArg *entries;
    status = [busObjectDescriptions value:@"a(oas)", &size, &entries];
    if (ER_OK != status) {
        NSLog(@"Failed to parse bus object descriptions.");
        return nil;
    }
    for (size_t i = 0; i < size; ++i) {
        char *objPath;
        size_t size2;
        MsgArg *entries2;
        status = entries[i].Get("(oas)", &objPath, &size2, &entries2);
        if (ER_OK != status) {
            NSLog(@"Failed to parse a bus object description. Skipping it...");
            continue;
        }
        for (size_t j = 0; j < size2; ++j) {
            char *iface;
            status = entries2[j].Get("s", &iface);
            if (ER_OK != status) {
                NSLog(@"Failed to parse a supported interface in a bus object."
                      " Skipping it...");
                continue;
            }
            [interfaces addObject:@(iface)];
        }
    }
    
    return interfaces;
}

+ (BOOL)isSupported:(AJNMessageArgument *)busObjectDescriptions
{
    if (!busObjectDescriptions) {
        return NO;
    }
    
    NSSet *interfaces =
    [DPAllJoynSupportCheck allInterfaceNamesFromBusObjectDescriptions:
     busObjectDescriptions];
    
    // Each supported AllJoyn interface set represents a collection of required AllJoyn
    // interfaces to realize a certain DeviceConnect profile (e.g. AllJoyn Lamp service
    // interfaces are required for the DeviceConnect Light profile).
    // If AllJoyn bus object in question contains any of supported interface sets, then
    // assumedly this bus object is able to become a DeviceConect service.
    for (NSArray *supportedInterfaceSet : DPAllJoynSupportedInterfaceSets) {
        if ([interfaces.allObjects containsAll:supportedInterfaceSet]) {
            return YES;
        }
    }
    return NO;
}


+ (NSArray *)supportedProfileNamesWithProvider:(id<DConnectProfileProvider>)provider
                                       service:(DPAllJoynServiceEntity *)service
{
    if (!provider) {
        return nil;
    }
    if (!service) {
        return nil;
    }
    
    NSSet *interfaces =
    [DPAllJoynSupportCheck allInterfaceNamesFromBusObjectDescriptions:
     service.proxyObjects];
    
    NSMutableArray *supportedProfileNames = [NSMutableArray array];
    
    for (DConnectProfile *profile in [provider profiles]) {
        // Prerequisite profiles.
        if ([profile isKindOfClass:DConnectServiceDiscoveryProfile.class]
            || [profile isKindOfClass:DConnectServiceInformationProfile.class]
            || [profile isKindOfClass:DConnectSystemProfile.class]
            ) {
            [supportedProfileNames addObject:profile.profileName];
        }
        // Optional profiles.
        else if ([profile isKindOfClass:DCMLightProfile.class]) {
            if ([interfaces.allObjects
                 containsAll:DPAllJoynLampControllerInterfaceSet]
                || [interfaces.allObjects
                    containsAll:DPAllJoynSingleLampInterfaceSet]) {
                    [supportedProfileNames addObject:profile.profileName];
            }
        }
    }
    
    return supportedProfileNames;
}

@end
