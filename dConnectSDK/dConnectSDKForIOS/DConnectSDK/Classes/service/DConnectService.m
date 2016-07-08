//
//  DConnectService.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectService.h"
#import "DConnectProfile.h"
#import "DConnectServiceInformationProfile.h"

@implementation DConnectService

- (instancetype) initWithServiceId: (NSString *)serviceId {
    if (!serviceId) {
        @throw @"id is null.";
    }
    self = [super init];
    if (self) {
        _mId = serviceId;
        _mProfiles = [NSMutableDictionary dictionary];
        [self addProfile: [[DConnectServiceInformationProfile alloc] init]];
    }
    return self;
}

/*!
 @brief サービスIDを取得する.
 @retval サービスID
 */
- (NSString *) serviceId {
    return _mId;
}

- (void) setName: (NSString *)name {
    _mName = name;
}

- (NSString *) name {
    return _mName;
}

/*
public void setNetworkType(final NetworkType type) {
    mType = type.getValue();
}
*/

- (void) setNetworkType: (NSString *) type {
    _mType = type;
}

- (NSString *) networkType {
    return _mType;
}

- (void) setOnline: (BOOL) isOnline {
    _mIsOnline = isOnline;
}
 
- (BOOL) isOnline {
    return _mIsOnline;
}

- (NSString *) config {
    return _mConfig;
}

- (void) setConfig: (NSString *) config {
    _mConfig = config;
}

// TODO: didReceiveRequestに名称変更。
- (BOOL) onRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *)response {
    DConnectProfile *profile = [self profileWithName: [request profile]];
    if (!profile) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    return [profile didReceiveRequest: request response: response];
}

#pragma mark - DConnectProfileProvider Implement.

- (NSArray *) profiles {
    
    // TODO: DConnectProfileのNSCopying対応。
    return [_mProfiles allValues];
}

- (DConnectProfile *) profileWithName: (NSString *) name {
    if (!name) {
        return nil;
    }
    return _mProfiles[[name lowercaseString]];
}

- (void) addProfile: (DConnectProfile *) profile {
    if (!profile) {
        return;
    }
// TODO: setServiceは#importの関係上実装が難しいので検討必要。
/*
    [profile setService: self];
*/
    NSString *profileName = [[profile profileName] lowercaseString];
    _mProfiles[profileName] = profile;
}

- (void) removeProfile: (DConnectProfile *) profile {
    if (!profile) {
        return;
    }
    NSString *profileName = [[profile profileName] lowercaseString];
    [_mProfiles removeObjectForKey: profileName];
}


@end
