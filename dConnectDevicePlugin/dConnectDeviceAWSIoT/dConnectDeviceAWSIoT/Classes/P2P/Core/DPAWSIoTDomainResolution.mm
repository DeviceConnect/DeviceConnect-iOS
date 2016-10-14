//
//  DPAWSIoTDomainResolution.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTDomainResolution.h"
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation DPAWSIoTDomainResolution {
    CFHostRef _host;
    HostResolutaionCallback _callback;
}

- (void) DomainResolutionError
{
    _callback(0, nil);
}

- (void) DomainResolutionDone
{
    Boolean resolved;
    NSArray *addresses = (__bridge NSArray *)CFHostGetAddressing(_host, &resolved);
    if (resolved && (addresses != nil)) {
        resolved = false;
        for (NSData *address in addresses) {
            const struct sockaddr *addrPtr;
            addrPtr = (const struct sockaddr *)[address bytes];
            if ([address length] >= sizeof(struct sockaddr) && addrPtr->sa_family == PF_INET) {
                // IPv4
                char *straddr = inet_ntoa(((struct sockaddr_in *)addrPtr)->sin_addr);
                NSString *s = [NSString stringWithCString:straddr encoding:NSASCIIStringEncoding];
                resolved = true;
                _callback(4, s);
            }
            if ([address length] >= sizeof(struct sockaddr) && addrPtr->sa_family == PF_INET6) {
                // IPv6
                struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addrPtr;
                char straddr[INET6_ADDRSTRLEN];
                inet_ntop(AF_INET6, &(addr6->sin6_addr), straddr, sizeof(straddr));
                NSString *s = [NSString stringWithCString:straddr encoding:NSASCIIStringEncoding];
                resolved = true;
                _callback(6, s);
            }
        }
    }
}

static void hostClientCallBack(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{
    DPAWSIoTDomainResolution *obj = (__bridge DPAWSIoTDomainResolution *)info;
    if ((error != NULL) && (error->domain != 0)) {
        [obj DomainResolutionError];
    } else {
        [obj DomainResolutionDone];
    }
}

- (void) resolveHostName:(NSString *)hostName callback:(HostResolutaionCallback)callback;
{
    CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    _host = CFHostCreateWithName(NULL, (__bridge CFStringRef)hostName);
    _callback = callback;
    
    CFHostSetClient(_host, hostClientCallBack, &context);
    CFHostScheduleWithRunLoop(_host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFStreamError streamError;
    Boolean success = CFHostStartInfoResolution(_host, kCFHostAddresses, &streamError);
    if (!success) {
        callback(0, nil);
    }
}

@end
