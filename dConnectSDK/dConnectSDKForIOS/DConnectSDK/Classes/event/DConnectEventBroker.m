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
    
    if ([self isServiceChangeEvent: event]) {
        [self onServiceChangeEvent: event];
        return;
    }
    
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
        DConnectDevicePlugin *plugin = [self.pluginManager devicePluginForPluginId: targetSession.pluginId];
        if (plugin) {
            [event setString:targetSession.receiverId forKey:DConnectMessageSessionKey];
            [event setString:[self.pluginManager appendServiceId: plugin serviceId: serviceId] forKey:DConnectMessageServiceId];
            [targetSession sendEvent: event];
        } else {
            DCLogW([NSString stringWithFormat: @"onEvent: Plugin is not found: id = %@", targetSession.pluginId]);
        }
    }
}


- (BOOL) isServiceChangeEvent: (DConnectMessage *) event {
    
    NSString *profileName = [event stringForKey: DConnectMessageProfile];
    NSString *attributeName = [event stringForKey:DConnectMessageAttribute];
    
    return profileName && [profileName localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileName] == NSOrderedSame
        && attributeName && [attributeName localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileAttrOnServiceChange] == NSOrderedSame;
}

- (void) onServiceChangeEvent: (DConnectMessage *) event {
    DConnectDevicePlugin *plugin = [self findPluginForServiceChange: event];
    if (!plugin) {
        DCLogW(@"onServiceChangeEvent: plugin is not found");
        return;
    }
    
//    // network service discoveryの場合には、networkServiceのオブジェクトの中にデータが含まれる
//    DConnectMessage *service = [event messageForKey:DConnectServiceDiscoveryProfileParamNetworkService];
//    NSString *serviceId = [service stringForKey:DConnectServiceDiscoveryProfileParamId];
    
    // サービスIDを変更
    [self replaceServiceId: event plugin: plugin];
    
    // 送信先のセッションを取得
    DConnectEventManager *eventManager = [DConnectEventManager sharedManagerForClass: self.context.class];
    NSArray * evts = [eventManager eventListForProfile:DConnectServiceDiscoveryProfileName
                                             attribute:DConnectServiceDiscoveryProfileAttrOnServiceChange];
    for (int i = 0; i < evts.count; i++) {
        DConnectEvent *evt = evts[i];
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [plugin sendEvent: eventMsg];
        // [Android]
//        mContext.sendEvent(evt.getReceiverName(), event);
    }
}

- (DConnectDevicePlugin *) findPluginForServiceChange: (DConnectMessage *) event {
    
    
    NSString *pluginAccessToken = [event stringForKey: DConnectMessageAccessToken];
    if (pluginAccessToken) {
        return [self.pluginManager devicePluginForServiceId: pluginAccessToken];
    } else {
        NSString *sessionKey = [event stringForKey:DConnectMessageSessionKey];
        if (sessionKey) {
            NSString *pluginId = [DConnectEventProtocol convertSessionKey2PluginId: sessionKey];
            return [self.pluginManager devicePluginForPluginId: pluginId];
        }
    }
    return nil;
}

- (void) replaceServiceId: (/*Intent*/DConnectMessage *)event plugin:(DConnectDevicePlugin *) plugin {
    NSString *serviceId = [event stringForKey: DConnectMessageServiceId];
    [event setString:[self.pluginManager appendServiceId: plugin serviceId: serviceId] forKey:DConnectMessageServiceId];
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
