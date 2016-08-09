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
@property(nonatomic, weak) id plugin_;

/*!
 @brief サポートするプロファイル一覧(key:プロファイル名(小文字) value:DConnectProfile *).
 */
@property(nonatomic, strong) NSMutableDictionary *profiles_;

@end

@implementation DConnectService

- (instancetype) initWithServiceId: (NSString *)serviceId {
    if (!serviceId) {
        @throw @"id is null.";
    }
    self = [super init];
    if (self) {
        [self setServiceId: serviceId];
        [self setProfiles_: [NSMutableDictionary dictionary]];
        [self addProfile: [[DConnectServiceInformationProfile alloc] init]];
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

- (void) setPlugin: (id) plugin {
    
    [self setPlugin_: plugin];
    
    // 登録済みのプロファイルデータにプラグインを設定する
    for (DConnectProfile *profile in [[self profiles_] allValues]) {
        [profile setProvider: plugin];
    }
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

    // プロファイルにデバイスプラグインのインスタンスを設定する
    [profile setProvider: [self plugin_]];
    
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
