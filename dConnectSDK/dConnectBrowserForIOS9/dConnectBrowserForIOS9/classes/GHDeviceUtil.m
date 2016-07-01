//
//  GHDeviceUtil.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceUtil.h"

@interface GHDeviceUtil()
{
    DConnectManager *manager;
    dispatch_queue_t q_global;
}
@end

@implementation GHDeviceUtil

- (instancetype)init
{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

- (void)setup
{
    manager = [DConnectManager sharedManager];
    [manager start];
    q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    __weak GHDeviceUtil *_self = self;
    [self requestAccessToken:^(NSString *accessToken) {
        _self.accessToken = accessToken;
        [_self discoverDevices:^(DConnectArray *result) {
            LOG(@"%d", [result count]);
        }];
    }];
}


- (void)discoverDevices:(DiscoverDeviceCompletion)completion
{
    // serviceDiscoveryを実行する
    DConnectRequestMessage *request = [DConnectRequestMessage new];
    [request setAction: DConnectMessageActionTypeGet];
    [request setApi: DConnectMessageDefaultAPI];
    [request setProfile: DConnectServiceDiscoveryProfileName];
    [request setAccessToken: _accessToken];
    [request setString:[self packageName] forKey:DConnectMessageOrigin];

    [manager sendRequest: request callback:^(DConnectResponseMessage *response) {
        if ([response result] == DConnectMessageResultTypeOk) {
            DConnectArray *result = [response arrayForKey: DConnectServiceDiscoveryProfileParamServices];
            if (completion) {
                completion(result);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)requestAccessToken:(void(^)(NSString *accessToken))completion
{
    NSArray *scopes = [@[DConnectServiceDiscoveryProfileName,
                         DConnectServiceDiscoveryProfileParamNetworkService,
                         DConnectServiceDiscoveryProfileParamState,
                         DConnectServiceDiscoveryProfileParamId,
                         DConnectServiceDiscoveryProfileParamName,
                         DConnectServiceDiscoveryProfileParamType,
                         DConnectServiceDiscoveryProfileParamOnline,
                         DConnectServiceDiscoveryProfileNetworkTypeWiFi,
                         DConnectServiceDiscoveryProfileNetworkTypeBluetooth,
                         DConnectServiceDiscoveryProfileNetworkTypeNFC,
                         DConnectServiceDiscoveryProfileNetworkTypeBLE
                         ]
                       sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    [DConnectUtil asyncAuthorizeWithOrigin: [self packageName]
                                   appName: @"dConnectBrowserForIOS9"
                                    scopes: scopes
                                   success: ^(NSString *clientId, NSString *accessToken) {
                                       LOG(@" - response - accessToken: %@", accessToken);
                                       if (completion) {
                                           completion(accessToken);
                                       }
                                   }
                                     error:^(DConnectMessageErrorCodeType errorCode){
                                         LOG(@" - response - errorCode: %d", errorCode);
                                         completion(nil);
                                     }];
}

// パッケージ名取得(bundleIdentifierを渡す)
- (NSString *)packageName {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *package = [bundle bundleIdentifier];
    return package;
}

@end
