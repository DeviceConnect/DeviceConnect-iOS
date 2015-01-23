//
//  DConnectManagerAvailabilityProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAvailabilityProfile.h"

// Profile Name
NSString *const DConnectAvailabilityProfileName = @"availability";

@implementation DConnectAvailabilityProfile

- (NSString *) profileName {
    return DConnectAvailabilityProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

@end