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

@interface DConnectService()


/*!
 @brief プラグインのインスタンス.
 */
@property(nonatomic, weak) id plugin;

/*!
 @brief サポートするプロファイル一覧(key:プロファイル名(小文字) value:DConnectProfile *).
 */
@property(nonatomic, strong) NSMutableDictionary *profiles_;

@end

@implementation DConnectService

- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id) plugin dataSource: (id<DConnectServiceInformationProfileDataSource>) dataSource {
    if (!serviceId) {
        @throw @"id is null.";
    }
    self = [super init];
    if (self) {
        [self setServiceId: serviceId];
        [self setPlugin: plugin];
        [self setProfiles_: [NSMutableDictionary dictionary]];
        
        DConnectServiceInformationProfile *serviceInformationProfile = [[DConnectServiceInformationProfile alloc] init];
        serviceInformationProfile.dataSource = dataSource;
        [self addProfile: serviceInformationProfile];
    }
    return self;
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
    return [[self profiles_] allValues];
}

- (DConnectProfile *) profileWithName: (NSString *) name {
    if (!name) {
        return nil;
    }
    return [self profiles_][[name lowercaseString]];
}

- (void) addProfile: (DConnectProfile *) profile {
    if (!profile) {
        return;
    }

    // プロファイルにプロファイルプロバイダとデバイスプラグインのインスタンスを設定する
    [profile setProvider: self];
    [profile setPlugin: [self plugin]];
    
    NSString *profileName = [[profile profileName] lowercaseString];
    [self profiles_][profileName] = profile;
}

- (void) removeProfile: (DConnectProfile *) profile {
    if (!profile) {
        return;
    }
    NSString *profileName = [[profile profileName] lowercaseString];
    [[self profiles_] removeObjectForKey: profileName];
}


@end
