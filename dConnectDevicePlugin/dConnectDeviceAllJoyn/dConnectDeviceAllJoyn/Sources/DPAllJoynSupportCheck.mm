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
#import "DPAllJoynConst.h"
#import "DPAllJoynServiceEntity.h"
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
        DCLogError(@"Failed to parse bus object descriptions.");
        return nil;
    }
    for (size_t i = 0; i < size; ++i) {
        char *objPath;
        size_t size2;
        MsgArg *entries2;
        status = entries[i].Get("(oas)", &objPath, &size2, &entries2);
        if (ER_OK != status) {
            DCLogError(@"Failed to parse a bus object description. Skipping it...");
            continue;
        }
        for (size_t j = 0; j < size2; ++j) {
            char *iface;
            status = entries2[j].Get("s", &iface);
            if (ER_OK != status) {
                DCLogError(@"Failed to parse a supported interface in a bus object."
                           " Skipping it...");
                continue;
            }
            [interfaces addObject:@(iface)];
        }
    }
    
    return interfaces;
}


+ (NSSet *)allInterfaceNamesFromService:(DPAllJoynServiceEntity *)service
{
    NSMutableSet *interfaces = [NSMutableSet new];
    
    for (NSArray *ifacesInObjPath in service.busObjectDescriptions.allValues) {
        [interfaces addObjectsFromArray:ifacesInObjPath];
    }
    
    return interfaces;
}


// =============================================================================
#pragma mark - Support check not considering object path.


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
    [DPAllJoynSupportCheck allInterfaceNamesFromService:service];
    
    NSMutableArray *supportedProfileNames = [NSMutableArray array];
    
    for (DConnectProfile *profile in [provider profiles]) {
        // Prerequisite profiles.
        if ([profile.profileName isEqualToString:DConnectServiceDiscoveryProfileName]
            || [profile.profileName isEqualToString:DConnectServiceInformationProfileName]
            || [profile.profileName isEqualToString:DConnectSystemProfileName]
            ) {
            [supportedProfileNames addObject:profile.profileName];
        }
        // Optional profiles.
        else if ([profile.profileName isEqualToString:DConnectLightProfileName]) {
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


+ (BOOL)areAJInterfacesSupported:(NSArray *)ifaces
                     withService:(DPAllJoynServiceEntity *)service
{
    if (!ifaces || ifaces.count == 0 || !service.busObjectDescriptions
        || service.busObjectDescriptions.count == 0) {
        return false;
    }
    
    NSSet *supportedInterfaces =
    [DPAllJoynSupportCheck allInterfaceNamesFromService:service];
    
    return [supportedInterfaces.allObjects containsAll:ifaces];
}


// =============================================================================
#pragma mark - Support check considering object path.


+ (NSDictionary *)objectPathDescriptionsWithInterface:(NSArray *)ifaces
                                              service:(DPAllJoynServiceEntity *)service
{
    if (!ifaces || ifaces.count == 0 || !service.busObjectDescriptions
        || service.busObjectDescriptions.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *busObjectDescriptions = [NSMutableDictionary dictionary];
    for (NSString *objPath in service.busObjectDescriptions) {
        NSArray *ifacesInObjPath = service.busObjectDescriptions[objPath];
        if ([ifacesInObjPath containsAll:ifaces]) {
            busObjectDescriptions[objPath] = ifacesInObjPath;
        }
    }
    
    return busObjectDescriptions;
}

@end
