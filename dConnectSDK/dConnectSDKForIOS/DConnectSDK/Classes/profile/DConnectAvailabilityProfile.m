//
//  DConnectManagerAvailabilityProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAvailabilityProfile.h"
#import "DConnectManager+Private.h"

// Profile Name
NSString *const DConnectAvailabilityProfileName = @"availability";
NSString *const DConnectAvailabilityProfileParamName = @"name";
NSString *const DConnectAvailabilityProfileParamUUID = @"uuid";


@implementation DConnectAvailabilityProfile

- (id) init {
    self = [super init];
    if (self) {
        
        NSString *getApiPath = [self apiPath: nil
                               attributeName: nil];
        [self addGetPath: getApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *name = [[DConnectManager sharedManager] managerName];
                         NSString *uuid = [[DConnectManager sharedManager] managerUUID];
                         [response setResult:DConnectMessageResultTypeOk];
                         [DConnectAvailabilityProfile setName:name target:response];
                         [DConnectAvailabilityProfile setUUID:uuid target:response];
                         return YES;
                     }];
    }
    return self;
}

- (NSString *) profileName {
    return DConnectAvailabilityProfileName;
}

+ (void) setName:(NSString *)name target:(DConnectMessage *)message {
    [message setString:name forKey:DConnectAvailabilityProfileParamName];
}

+ (void) setUUID:(NSString *)uuid target:(DConnectMessage *)message {
    [message setString:uuid forKey:DConnectAvailabilityProfileParamUUID];
}

@end
