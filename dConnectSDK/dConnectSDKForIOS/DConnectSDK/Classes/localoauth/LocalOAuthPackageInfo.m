//
//  LocalOAuthPackageInfo.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuthPackageInfo.h"

@implementation LocalOAuthPackageInfo

- (LocalOAuthPackageInfo *) initWithPackageName: (NSString *)packageName {
    
    self = [super init];
    
    if (self) {
        self.packageName = packageName;
        self.serviceId = nil;
    }
    
    return self;
}

- (LocalOAuthPackageInfo *) initWithPackageNameServiceId: (NSString *)packageName serviceId:(NSString *)serviceId {
    
    self = [super init];
    
    self.packageName = packageName;
    self.serviceId = serviceId;
    
    return self;
}

- (BOOL)equals:(LocalOAuthPackageInfo *)info {
    
    LocalOAuthPackageInfo *cmp1 = self;
    LocalOAuthPackageInfo *cmp2 = info;
    
    BOOL isEqualPackageName = NO;
    if (cmp1.packageName == nil && cmp2.packageName == nil) {
        isEqualPackageName = YES;
    } else if (cmp1.packageName != nil
               && cmp2.packageName != nil
               && [cmp1.packageName isEqualToString: cmp2.packageName] ) {
        isEqualPackageName = YES;
    }
    
    BOOL isEqualServiceId = NO;
    if (cmp1.serviceId == nil && cmp2.serviceId == nil) {
        isEqualServiceId = YES;
    } else if (cmp1.serviceId != nil && cmp2.serviceId != nil
               && [cmp1.serviceId isEqualToString: cmp2.serviceId]) {
        isEqualServiceId = YES;
    }
    
    if (isEqualPackageName && isEqualServiceId) {
        return YES;
    }
    return NO;
}


@end
