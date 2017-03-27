//
//  DConnectManagerAvailabilityProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAvailabilityProfile.h"
#import "DConnectManager.h"

// Profile Name
NSString *const DConnectAvailabilityProfileName = @"availability";
NSString *const DConnectAvailabilityProfileParamName = @"name";


@implementation DConnectAvailabilityProfile

- (id) init {
    self = [super init];
    if (self) {
        
        NSString *getApiPath = [self apiPath: nil
                               attributeName: nil];
        [self addGetPath: getApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         [response setResult:DConnectMessageResultTypeOk];
                         BOOL useManagerName = [DConnectManager sharedManager].settings.useManagerName;
                         if (useManagerName) {
                             NSString *name = [[DConnectManager sharedManager] managerName];
                             [DConnectAvailabilityProfile setName:name target:response];
                         }
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

@end
