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

- (id) init {
    self = [super init];
    if (self) {
        
        NSString *getApiPath = [self apiPathWithProfileInterfaceAttribute: [self profileName]
                                                                        interfaceName: nil
                                                                        attributeName: nil];
        [self addGetPath: getApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return YES;
                     }];
    }
    return self;
}

- (NSString *) profileName {
    return DConnectAvailabilityProfileName;
}

@end
