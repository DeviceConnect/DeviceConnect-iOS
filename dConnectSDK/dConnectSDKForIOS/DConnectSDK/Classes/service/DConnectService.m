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

@interface DConnectService() {
    
    /*!
     @brief サービスID.
     */
    NSString *mId;
    
    /*!
     @brief サポートするプロファイル一覧(key:プロファイル名(小文字) value:DConnectProfile *).
     */
    NSMutableDictionary *mProfiles;
    
    NSString *mName;
    
    NSString *mType;
    
    BOOL mIsOnline;
    
    NSString *mConfig;
}

@end

@implementation DConnectService

- (instancetype) initWithServiceId: (NSString *)serviceId {
    if (!serviceId) {
        @throw @"id is null.";
    }
    self = [super init];
    if (self) {
        mId = serviceId;
        mProfiles = [NSMutableDictionary dictionary];
        [self addProfile: [[DConnectServiceInformationProfile alloc] init]];
    }
    return self;
}

/*!
 @brief サービスIDを取得する.
 @retval サービスID
 */
- (NSString *) serviceId {
    return mId;
}

- (void) setName: (NSString *)name {
    mName = name;
}

- (NSString *) name {
    return mName;
}

/*
public void setNetworkType(final NetworkType type) {
    mType = type.getValue();
}
*/

- (void) setNetworkType: (NSString *) type {
    mType = type;
}

- (NSString *) networkType {
    return mType;
}

- (void) setOnline: (BOOL) isOnline {
    mIsOnline = isOnline;
}
 
- (BOOL) isOnline {
    return mIsOnline;
}

- (NSString *) config {
    return mConfig;
}

- (void) setConfig: (NSString *) config {
    mConfig = config;
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
    return [mProfiles allValues];
}

- (DConnectProfile *) profileWithName: (NSString *) name {
    if (!name) {
        return nil;
    }
    return mProfiles[[name lowercaseString]];
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
    mProfiles[profileName] = profile;
}

- (void) removeProfile: (DConnectProfile *) profile {
    if (!profile) {
        return;
    }
    NSString *profileName = [[profile profileName] lowercaseString];
    [mProfiles removeObjectForKey: profileName];
}


@end
