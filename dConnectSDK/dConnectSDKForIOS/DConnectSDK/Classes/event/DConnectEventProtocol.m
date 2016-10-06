//
//  DConnectEventProtocol.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEventProtocol.h"
#import "DConnectVersionName.h"
#import "DConnectDevicePluginManager.h"
#import "DConnectMessageEventSession.h"

static DConnectVersionName *V100;

static DConnectVersionName *V110;

/*!
 @brief イベントセッションを作成するblocks。
 
 @param response レスポンスメッセージ
 */
typedef DConnectEventSession * (^CreateSessionBlocks)(DConnectMessage *request, NSString *serviceId, NSString *receiverId, NSString *pluginId);


@interface DConnectEventProtocol()

@property(nonatomic, weak) DConnectManager *context;

@property(nonatomic, weak) DConnectWebSocket *webSocket;

@property(nonatomic, strong) CreateSessionBlocks createSessionBlocks;

@end

@implementation DConnectEventProtocol

- (instancetype) initWithContext: (DConnectManager *) context webSocket: (DConnectWebSocket *)webSocket createSessionBlocks: (CreateSessionBlocks) createSessionBlocks {
    
    self = [super init];
    if (self) {
        if (!V100 || !V110) {
            V100 = [DConnectVersionName parse: @"1.0.0"];
            V110 = [DConnectVersionName parse: @"1.1.0"];
        }
        self.context = context;
        self.webSocket = webSocket;
        self.createSessionBlocks = createSessionBlocks;
    }
    return self;
}

- (BOOL) removeSession: (DConnectEventSessionTable *) table request: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) plugin {
    NSString *serviceId = [DConnectDevicePluginManager splitServiceId: plugin serviceId: [request stringForKey:DConnectMessageServiceId]];
    NSString *receiverId = [DConnectEventProtocol createReceiverId: self.messageService  request:request];
    if (!receiverId) {
        return NO;
    }
    
    if (self.createSessionBlocks) {
        DConnectEventSession *query = self.createSessionBlocks(request, serviceId, receiverId, plugin.pluginId);
        
        for (DConnectEventSession *session in table.all) {
            if ([self isSameSession: query cmp:session]) {
                [table remove: session];

                // TODO: iOSはSDKとプラグインは同梱なのでバージョン違いは起きないため、互換処理は不要？
                // [Android]
//                if (plugin.getPluginSdkVersionName().compareTo(V100) == 0) {
//                    DConnectProfile.setSessionKey(request, createSessionKeyForPlugin(session));
//                }
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) addSession: (DConnectEventSessionTable *) table request: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) plugin {
    NSString *accessToken = [request stringForKey:DConnectMessageAccessToken];
    if (!accessToken) {
        [request setString:plugin.pluginId forKey:DConnectMessageAccessToken];
    }
    
    NSString *serviceId = [DConnectDevicePluginManager splitServiceId: plugin serviceId: [request stringForKey:DConnectMessageServiceId]];
    NSString *receiverId = [DConnectEventProtocol createReceiverId: self.messageService request: request];
    if (!receiverId) {
        return NO;
    }
    
    if (self.createSessionBlocks) {
        DConnectEventSession *session = self.createSessionBlocks(request, serviceId, receiverId, plugin.pluginId);
        [table add: session];
        
        // TODO: iOSはSDKとプラグインは同梱なのでバージョン違いは起きないため、互換処理は不要？
        // [Android]
//        if (plugin.getPluginSdkVersionName().compareTo(V100) == 0) {
//            DConnectProfile.setSessionKey(request, createSessionKeyForPlugin(session));
//        }
    }
    return YES;
}

- (BOOL) isSameSession: (DConnectEventSession *) a cmp: (DConnectEventSession *) b {
    
    return [self isSame: a.receiverId cmp: b.receiverId]
    && [self isSame: a.serviceId cmp: b.serviceId]
    && [self isSame: a.pluginId cmp: b.pluginId]
    && [self isSameIgnoreCase: a.profileName cmp: b.profileName] // MEMO パスの大文字小文字を無視
    && [self isSameIgnoreCase: a.interfaceName cmp: b.interfaceName]
    && [self isSameIgnoreCase: a.attributeName cmp: b.attributeName];
}

- (BOOL) isSame: (NSString *) a cmp: (NSString *) b {
    if (!a && !b) {
        return YES;
    }
    if ((a && !b) || (!a && b)) {
        return NO;
    }
    return [a isEqualToString: b];
}

- (BOOL) isSameIgnoreCase: (NSString *) a cmp: (NSString *) b {
    if (!a && !b) {
        return YES;
    }
    if ((a && !b) || (!a && b)) {
        return NO;
    }
    return [a localizedCaseInsensitiveCompare: b] == NSOrderedSame;
}


#pragma marker - Static Methods.

+ (DConnectEventProtocol *) getInstance: (DConnectManager *) context
                                request: (DConnectMessage *) request
                               delegate: (id<DConnectManagerDelegate>) delegate
                              webSocket: (DConnectWebSocket *) webSocket
{
    NSString *appType = [request stringForKey: DConnectServiceInnerType];
    if ([appType isEqualToString: DConnectServiceInnerTypeHttp]) {
        CreateSessionBlocks blocks = ^(DConnectMessage *request, NSString *serviceId, NSString *receiverId, NSString *pluginId) {
            NSString *accessToken = [request stringForKey:DConnectMessageAccessToken];
            NSString *profileName = [request stringForKey:DConnectMessageProfile];
            NSString *interfaceName = [request stringForKey:DConnectMessageInterface];
            NSString *attributeName = [request stringForKey:DConnectMessageAttribute];
            NSString *origin = [request stringForKey:DConnectMessageOrigin];
            
            DConnectMessageEventSession *session = [[DConnectMessageEventSession alloc] initWithDelegate:delegate webSocket:webSocket origin:origin];
            [session setAccessToken: accessToken];
            [session setReceiverId: receiverId];
            [session setServiceId: serviceId];
            [session setPluginId: pluginId];
            [session setProfileName: profileName];
            [session setInterfaceName: interfaceName];
            [session setAttributeName: attributeName];
            [session setContext: context];
            return session;
        };
        return [[DConnectEventProtocol alloc] initWithContext:context webSocket:webSocket createSessionBlocks:blocks];
    } else {
        DCLogW(@"getInstance : not support apptype. %@", appType);
        return nil;
    }
}

+ (NSString *) createSessionKeyForPlugin: (DConnectEventSession *) session {
    
    NSString *separator = @".";
    
    NSMutableString *result = [NSMutableString string];
    [result appendString: session.receiverId];
    [result appendString: separator];
    [result appendString: session.pluginId];
    return result;
}


+ (NSString *) createReceiverId: (/*)DConnectMessageService*/DConnectManager *) messageService
                        request: (DConnectMessage *) request {
    
    NSString *origin = [request stringForKey: DConnectMessageOrigin];
    if (!origin && !messageService.requiresOrigin) {
        origin = DConnectServiceAnonymousOrigin;
    }
    
    NSString *receiverId;
    NSString *sessionKey = [request stringForKey:DConnectMessageSessionKey];
    if (sessionKey) {
        receiverId = sessionKey;
    } else {
        receiverId = origin;
    }
    return receiverId;
}

/*!
 * @brief セッションキーからプラグインIDに変換する.
 *
 * @param[in] sessionKey セッションキー
 * @retval プラグインID
 */
+ (NSString *) convertSessionKey2PluginId: (NSString *) sessionKey {
    
    NSRange range = [sessionKey rangeOfString:@"." options:NSBackwardsSearch];
    NSUInteger index = range.location;
    if (index != NSNotFound) {
        return [sessionKey substringFromIndex:(index + 1)];
    }
    return sessionKey;
}

/*!
 * @brief デバイスプラグインからのセッションキーから前半分のクライアントのセッションキーに変換する.
 * @param[in] sessionKey セッションキー
 * @retval クライアント用のセッションキー
 */
+ (NSString *) convertSessionKey2Key: (NSString *) sessionKey {
    
    NSRange range = [sessionKey rangeOfString:@"." options:NSBackwardsSearch];
    NSUInteger index = range.location;
    if (index != NSNotFound) {
        return [sessionKey substringWithRange: NSMakeRange(0, index)];
    }
    return sessionKey;
}

+ (DConnectRequestMessage *) createRegistrationRequestForServiceChange: (DConnectManager *) context
                                                                plugin: (DConnectDevicePlugin *) plugin {
    NSString *profileName = DConnectServiceDiscoveryProfileName;
    NSString *attributeName = DConnectServiceDiscoveryProfileAttrOnServiceChange;
    
    DConnectRequestMessage *request = [self createRegistrationRequest: context
                                                               plugin:plugin
                                                          profileName:profileName
                                                        interfaceName:nil
                                                        attributeName:attributeName];
    
    if ([[plugin pluginVersionName] isEqualToString: [V110 toString]]) {
        // NOTE: イベントハンドラーがあとでプラグインを特定するための情報
        [request setAccessToken: plugin.pluginId];
    }
    return request;
}

+ (DConnectRequestMessage *) createRegistrationRequest: (DConnectManager *) context
                                                plugin: (DConnectDevicePlugin *) plugin
                                           profileName: (NSString *) profileName
                                         interfaceName: (NSString *) interfaceName
                                         attributeName: (NSString *) attributeName {
    
    return [self createEventRequest: context
                             action: DConnectMessageActionTypePut
                             plugin: plugin
                        profileName: profileName
                      interfaceName: interfaceName
                      attributeName: attributeName];
}

+ (DConnectRequestMessage *) createUnregistrationRequest: (DConnectManager *) context
                                                  plugin: (DConnectDevicePlugin *) plugin
                                             profileName: (NSString *) profileName
                                           interfaceName: (NSString *) interfaceName
                                           attributeName: (NSString *) attributeName {
    
    return [self createEventRequest: context
                             action: DConnectMessageActionTypeDelete
                             plugin: plugin
                        profileName: profileName
                      interfaceName: interfaceName
                      attributeName: attributeName];
}

+ (DConnectRequestMessage *) createEventRequest: (DConnectManager *) context
                                         action: (DConnectMessageActionType) action
                                         plugin: (DConnectDevicePlugin *) plugin
                                    profileName: (NSString *) profileName
                                  interfaceName: (NSString *) interfaceName
                                  attributeName: (NSString *) attributeName {

    DConnectRequestMessage *request = [DConnectRequestMessage new];
    [request setAction: action];
    //[Android]
    //request.setFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES);
    //request.setComponent(plugin.getComponentName());
    [request setProfile: profileName];
    [request setInterface: interfaceName];
    [request setAttribute:attributeName];
    //[Android]
    //[request.putExtra(DConnectMessage.EXTRA_RECEIVER,
    //                 new ComponentName(context, DConnectBroadcastReceiver.class));
    // TODO: iOSはSDKとプラグインは同梱なのでバージョン違いは起きないため、互換処理は不要？
    // [Android]
//    if (plugin.getPluginSdkVersionName().compareTo(V100) == 0) {
//        request.putExtra(DConnectMessage.EXTRA_SESSION_KEY, plugin.getServiceId());
//    }
    return request;
}

@end

