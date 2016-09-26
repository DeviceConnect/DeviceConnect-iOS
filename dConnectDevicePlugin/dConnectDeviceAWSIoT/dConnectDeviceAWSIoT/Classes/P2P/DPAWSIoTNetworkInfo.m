//
//  DPAWSIoTNetworkInfo.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTNetworkInfo.h"
#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation DPAWSIoTNetworkInfo

+ (NSDictionary *) getNetworkInfo
{
    struct ifaddrs *ifa_list;
    char addrstr[256];
    char netmaskstr[256];
    
    NSMutableDictionary *netInfo = [NSMutableDictionary dictionary];
    if (getifaddrs(&ifa_list) != 0) {
        return netInfo;
    }
    
    for (struct ifaddrs *ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
        if (ifa->ifa_addr->sa_family == AF_INET) {
            memset(addrstr, 0, sizeof(addrstr));
            memset(netmaskstr, 0, sizeof(netmaskstr));
            inet_ntop(AF_INET, &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr, addrstr, sizeof(addrstr));
            inet_ntop(AF_INET, &((struct sockaddr_in *)ifa->ifa_netmask)->sin_addr, netmaskstr, sizeof(netmaskstr));
            
            NSArray *deviceInfo = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%s", addrstr],
                          [NSString stringWithFormat:@"%s", netmaskstr], nil];
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithObjectsAndKeys:deviceInfo,
                                         [NSString stringWithFormat:@"%s", ifa->ifa_name], nil];
            
            [netInfo addEntriesFromDictionary:temp];
        }
    }
    freeifaddrs(ifa_list);
    return netInfo;
}

+ (NSString *) getLocalIp
{
    NSDictionary *netInfo = [DPAWSIoTNetworkInfo getNetworkInfo];
    if ([netInfo count] == 0) {
        return nil;
    }
    
    NSArray *deviceInfo = [netInfo valueForKey:@"en0"];
    if (deviceInfo == nil) {
        deviceInfo = [netInfo valueForKey:@"lo0"];
        if (deviceInfo == nil) {
            return [NSString stringWithFormat:@""];
        }
    }
    return [deviceInfo objectAtIndex:0];
}

+ (NSString *) getGlobalIp
{
    NSDictionary *netInfo = [DPAWSIoTNetworkInfo getNetworkInfo];
    if ([netInfo count] == 0) {
        return nil;
    }

    NSArray * deviceInfo = [netInfo valueForKey:@"pdp_ip0"];
    if (deviceInfo == nil) {
        return [NSString stringWithFormat:@""];
    }
    return [deviceInfo objectAtIndex:0];
}

@end
