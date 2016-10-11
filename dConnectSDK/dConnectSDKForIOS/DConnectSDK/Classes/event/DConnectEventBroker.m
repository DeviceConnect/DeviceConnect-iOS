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

@property(nonatomic, weak) DConnectManager *context;

@property(nonatomic, weak) DConnectLocalOAuthDB *localOAuth;

@property(nonatomic, weak) DConnectDevicePluginManager *pluginManager;

@property(nonatomic, strong) id<DConnectEventRegistrationListener> listener;

@property(nonatomic, weak) id<DConnectManagerDelegate> delegate;

@end

@implementation DConnectEventBroker

/*public EventBroker() コンストラクタ */
- (instancetype) initWithContext : (DConnectManager *) context
                            table: (DConnectEventSessionTable *) table
                       localOAuth: (DConnectLocalOAuthDB *) localOAuth
                    pluginManager: (DConnectDevicePluginManager *)pluginManager
                         delegate: (id<DConnectManagerDelegate>) delegate
{
    self = [super init];
    
    if (self) {
        self.table = table;
        self.context = context;
        self.localOAuth = localOAuth;
        self.pluginManager = pluginManager;
        self.delegate = delegate;
    }

    return self;
}

- (void) setRegistrationListener: (id<DConnectEventRegistrationListener>) listener {
    self.listener = listener;
}

- (void) onRequest: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) dest webSocket: (DConnectWebSocket *) webSocket {
    
    NSString *serviceId = [request stringForKey: DConnectMessageServiceId];
    if (!serviceId) {
        return;
    }
    NSString *origin = [request stringForKey: DConnectMessageOrigin];
    if (!origin) {
        return;
    }
    NSString *accessToken = [self getAccessToken: serviceId origin:origin];
    if (accessToken) {
        [request setString:accessToken forKey:DConnectMessageAccessToken];
    } else {
        [request setString:nil forKey:DConnectMessageAccessToken];
    }
    
    if ([self isRegistrationRequest: request]) {
        [self onRegistrationRequest: request plugin: dest webSocket: webSocket];
    } else if ([self isUnregistrationRequest: request]) {
        [self onUnregistrationRequest: request plugin: dest webSocket: webSocket];
    }
}

- (void) onRegistrationRequest: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) dest webSocket: (DConnectWebSocket *) webSocket {

    DConnectEventProtocol *protocol = [DConnectEventProtocol getInstance:self.context request:request delegate:self.delegate webSocket:webSocket];
    if (!protocol) {
        DCLogW(@"Failed to identify a event receiver.");
        return;
    }
    [protocol addSession: self.table request: request plugin: dest];
    
    if (self.listener) {
        [self.listener onPutEventSession: request plugin: dest];
    }
}

- (void) onUnregistrationRequest: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) dest webSocket: (DConnectWebSocket *) webSocket {

    DConnectEventProtocol *protocol = [DConnectEventProtocol getInstance:self.context request:request delegate:self.delegate webSocket:webSocket];
    if (!protocol) {
        DCLogW(@"Failed to identify a event receiver.");
        return;
    }
    [protocol removeSession: self.table request: request plugin: dest];
    
    if (self.listener) {
        [self.listener onDeleteEventSession:request plugin:dest];
    }
}

- (NSString *) getAccessToken: (NSString *) serviceId origin:(NSString *) origin {
    DConnectAuthData *oauth = [self.localOAuth getAuthDataByServiceId: serviceId];
    if (oauth) {
        return [self.localOAuth getAccessTokenByAuthData: oauth];
    }
    return nil;
}

- (void) onEvent:(DConnectMessage *) event plugin:(DConnectDevicePlugin *)plugin{
    
    if ([self isServiceChangeEvent: event]) {
        [self onServiceChangeEvent: event];
        return;
    }
    
    NSString *pluginAccessToken = [event stringForKey:DConnectMessageAccessToken];
    NSString *serviceId = [event stringForKey:DConnectMessageServiceId];
    NSString *profileName = [event stringForKey: DConnectMessageProfile];
    NSString *interfaceName = [event stringForKey: DConnectMessageInterface];
    NSString *attributeName = [event stringForKey: DConnectMessageAttribute];
    
    NSString *serviceId_ = [DConnectDevicePluginManager splitServiceId:plugin serviceId: serviceId];
    NSString *pluginId = plugin.pluginId;
    
    DConnectEventSession *targetSession = nil;
    if (pluginAccessToken) {
        for (DConnectEventSession *session in [self.table all]) {
            if ([self isSameNameCaseSensitive: pluginAccessToken cmp: session.accessToken] &&
                [self isSameNameCaseSensitive: serviceId_ cmp: session.serviceId] &&
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
            NSString *receiverId = [DConnectEventProtocol convertSessionKey2Key: sessionKey];
            for (DConnectEventSession *session in [self.table all]) {
                if ([self isSameNameCaseSensitive: pluginId cmp: session.pluginId] &&
                    [self isSameNameCaseSensitive: receiverId cmp: session.receiverId] &&
                    [self isSameNameCaseSensitive: serviceId_ cmp: session.serviceId] &&
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
        NSString *pluginId;
        NSArray *pluginIdParts = [targetSession.pluginId componentsSeparatedByString:@"."];
        if (pluginIdParts.count > 1) {
            pluginId = pluginIdParts[0];
        } else {
            pluginId = targetSession.pluginId;
        }
        DConnectDevicePlugin *plugin = [self.pluginManager devicePluginForPluginId: pluginId];
        if (plugin) {
            [event setString:targetSession.receiverId forKey:DConnectMessageSessionKey];
            [event setString:[self.pluginManager serviceIdByAppedingPluginIdWithDevicePlugin:plugin serviceId:serviceId_] forKey:DConnectMessageServiceId];
            [targetSession sendEvent: event];
        } else {
            DCLogW(@"onEvent: Plugin is not found: id = %@", targetSession.pluginId);
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

- (void) replaceServiceId:(DConnectMessage *)event plugin:(DConnectDevicePlugin *) plugin {
    NSString *serviceId = [event stringForKey: DConnectMessageServiceId];
    [event setString:[self.pluginManager serviceIdByAppedingPluginIdWithDevicePlugin:plugin serviceId:serviceId] forKey:DConnectMessageServiceId];
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

- (BOOL) isSameNameCaseSensitive: (NSString *) str cmp: (NSString *) cmp {
    if (!str && !cmp) {
        return YES;
    } else if (!str || !cmp) {
        return NO;
    } else if ([str localizedCompare: cmp] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) isRegistrationRequest: (DConnectMessage *) request {
    DConnectMessageActionType action = (DConnectMessageActionType)[request integerForKey:DConnectMessageAction];
    return action == DConnectMessageActionTypePut;
}

- (BOOL) isUnregistrationRequest: (DConnectMessage *) request {
    DConnectMessageActionType action = (DConnectMessageActionType)[request integerForKey:DConnectMessageAction];
    return action == DConnectMessageActionTypeDelete;
}

@end
