//
//  EventBroker.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEventBroker.h"
#import <DConnectSDK/DConnectSDK.h>
#import "DConnectDevicePluginManager.h"
#import "DConnectEventProtocol.h"

@interface DConnectEventBroker()

@property(nonatomic, weak) DConnectEventSessionTable *table;

@property(nonatomic, weak) /*DConnectMessageService*/DConnectManager *context;

@property(nonatomic, weak) /*DConnectLocalOAuth*/DConnectLocalOAuthDB *localOAuth;

@property(nonatomic, weak) DConnectDevicePluginManager *pluginManager;

@property(nonatomic, strong) id<DConnectEventRegistrationListener> listener;

@end

@implementation DConnectEventBroker

/*public EventBroker() コンストラクタ */
- (instancetype) initWithContext : (/* DConnectMessageService */DConnectManager *) context
                            table: (DConnectEventSessionTable *) table
                       localOAuth: (DConnectLocalOAuthDB *) localOAuth
                    pluginManager: (DConnectDevicePluginManager *)pluginManager {
    self = [super init];
    
    if (self) {
        self.table = table;
        self.context = context;
        self.localOAuth = localOAuth;
        self.pluginManager = pluginManager;
    }

    return self;
}

- (void) setRegistrationListener: (id<DConnectEventRegistrationListener>) listener {
    self.listener = listener;
}

- (void) onRequest: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) dest {
    NSString *serviceId = [request serviceId];
    if (!serviceId) {
        return;
    }
    NSString *accessToken = [self getAccessToken: serviceId];
    if (accessToken) {
        [request setAccessToken: accessToken];
    } else {
        [request setAccessToken: nil];
    }
    
    if ([self isRegistrationRequest: request]) {
        [self onRegistrationRequest: request plugin: dest];
    } else if ([self isUnregistrationRequest: request]) {
        [self onUnregistrationRequest: request plugin: dest];
    }
}

- (void) onRegistrationRequest: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) dest {
    DConnectEventProtocol *protocol = [DConnectEventProtocol getInstance:self.context request:request];
    if (!protocol) {
        DCLogW(@"Failed to identify a event receiver.");
        return;
    }
    [protocol addSession: self.table request: request plugin: dest];
    
    if (self.listener) {
        [self.listener onPutEventSession: request plugin: dest];
    }
}

- (void) onUnregistrationRequest: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) dest {

    DConnectEventProtocol *protocol = [DConnectEventProtocol getInstance:self.context request:request];
    if (!protocol) {
        DCLogW(@"Failed to identify a event receiver.");
        return;
    }
    [protocol removeSession: self.table request: request plugin: dest];
    
    if (self.listener) {
        [self.listener onDeleteEventSession:request plugin:dest];
    }
}

- (NSString *) getAccessToken: (NSString *) serviceId {
    DConnectAuthData *oauth = [self.localOAuth getAuthDataByServiceId: serviceId];
    if (oauth) {
        return [self.localOAuth getAccessTokenByAuthData: oauth];
    }
    return nil;
}

- (void) onEvent: (/* Intent */ DConnectMessage *) event {
    
    // TODO: この処理は不要？
    // [Android]
//    if ([self isServiceChangeEvent: event]) {
//        [self onServiceChangeEvent: event];
//        return;
//    }
    
    NSString *pluginAccessToken = [event stringForKey:DConnectMessageAccessToken];
    NSString *serviceId = [event stringForKey:DConnectMessageServiceId];
    NSString *profileName = [event stringForKey: DConnectMessageProfile];
    NSString *interfaceName = [event stringForKey: DConnectMessageInterface];
    NSString *attributeName = [event stringForKey: DConnectMessageAttribute];
    
    DConnectEventSession *targetSession = nil;
    if (pluginAccessToken) {
        for (DConnectEventSession *session in [self.table all]) {
            if ([self isSameName: pluginAccessToken cmp: session.accessToken] &&
                [self isSameName: serviceId cmp: session.serviceId] &&
                [self isSameName: profileName cmp: session.profileName] &&
                [self isSameName: interfaceName cmp: session.interfaceName] &&
                [self isSameName: attributeName cmp: session.attributeName]) {
                targetSession = session;
                break;
            }
        }
    } else {
        NSString *sessionKey = [event stringForKey: DConnectMessageSessionKey];
        if (sessionKey) {
            NSString *pluginId = [DConnectEventProtocol convertSessionKey2PluginId: sessionKey];
            NSString *receiverId = [DConnectEventProtocol convertSessionKey2Key: sessionKey];
            for (DConnectEventSession *session in [self.table all]) {
                if ([self isSameName: pluginId cmp: session.pluginId] &&
                    [self isSameName: receiverId cmp: session.receiverId] &&
                    [self isSameName: serviceId cmp: session.serviceId] &&
                    [self isSameName: profileName cmp: session.profileName] &&
                    [self isSameName: interfaceName cmp: session.interfaceName] &&
                    [self isSameName: attributeName cmp: session.attributeName]) {
                    targetSession = session;
                    break;
                }
            }
        }
    }
    if (targetSession) {
        [event setString:targetSession.receiverId forKey:DConnectMessageSessionKey];
        [targetSession sendEvent: event];
    }
}

- (BOOL) isServiceChangeEvent: (DConnectMessage *) event {
    
    NSString *profileName = [event stringForKey: DConnectMessageProfile];
    NSString *attributeName = [event stringForKey:DConnectMessageAttribute];
    
    return profileName && [profileName localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileName] == NSOrderedSame
        && attributeName && [attributeName localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileAttrOnServiceChange] == NSOrderedSame;
}

- (BOOL) isSameName: (NSString *) str cmp: (NSString *) cmp {
    if (!str && !cmp) {
        return YES;
    } else if (!str || !cmp) {
        return NO;
    } else if ([str localizedCaseInsensitiveCompare: cmp] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) isRegistrationRequest: (DConnectRequestMessage *) request {
    return request.action == DConnectMessageActionTypePut;
}

- (BOOL) isUnregistrationRequest: (DConnectRequestMessage *) request {
    return request.action == DConnectMessageActionTypeDelete;
}

@end
