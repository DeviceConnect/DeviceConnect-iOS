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
        
        [self addApi: [[DConnectAvailabilityGetApi alloc] init]];
    }
    return self;
}

- (NSString *) profileName {
    return DConnectAvailabilityProfileName;
}

@end


#pragma mark - DConnectAvailabilityGetApi

@implementation DConnectAvailabilityGetApi

#pragma mark - DConnectApiDelegate Implement.

- (BOOL)onRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

@end

