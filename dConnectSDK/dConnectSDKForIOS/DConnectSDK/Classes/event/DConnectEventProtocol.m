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
#import "CipherSignatureFactory.h"

static DConnectVersionName *V100;

static DConnectVersionName *V110;

/*!
 @brief イベントセッションを作成するblocks。
 
 @param response レスポンスメッセージ
 */
typedef DConnectEventSession * (^CreateSessionBlocks)(DConnectRequestMessage *request, NSString *serviceId, NSString *receiverId, NSString *pluginId);


@interface DConnectEventProtocol()

@property(nonatomic, strong) CreateSessionBlocks createSessionBlocks;

@end

@implementation DConnectEventProtocol

- (instancetype) initWithContext: (DConnectManager *) context createSessionBlocks: (CreateSessionBlocks) createSessionBlocks {
    
    self = [super init];
    if (self) {
        if (!V100 || !V110) {
            V100 = [DConnectVersionName parse: @"1.0.0"];
            V110 = [DConnectVersionName parse: @"1.1.0"];
            self.createSessionBlocks = createSessionBlocks;
        }
    }
    return self;
}

- (BOOL) removeSession: (DConnectEventSessionTable *) table request: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) plugin {
    NSString *serviceId = [DConnectDevicePluginManager splitServiceId: plugin serviceId: request.serviceId];
    NSString *receiverId = [DConnectEventProtocol createReceiverId: self.messageService  request:request];
    if (!receiverId) {
        return NO;
    }
    
    if (self.createSessionBlocks) {
        DConnectEventSession *query = self.createSessionBlocks(request, serviceId, receiverId, plugin.pluginId);
        
        for (DConnectEventSession *session in table.all) {
            if ([self isSameSession: query cmp:session]) {
                [table remove: session];

                if ([[plugin pluginVersionName] isEqualToString: [V100 toString]]) {
                    [request setSessionKey: [DConnectEventProtocol createSessionKeyForPlugin: session]];
                }
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) addSession: (DConnectEventSessionTable *) table request: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) plugin {
    NSString *accessToken = [request accessToken];
    if (!accessToken) {
        [request setAccessToken: plugin.pluginId];
    }
    
    NSString *serviceId = [DConnectDevicePluginManager splitServiceId: plugin serviceId: request.serviceId];
    NSString *receiverId = [DConnectEventProtocol createReceiverId: self.messageService request: request];
    if (!receiverId) {
        return NO;
    }
    
    if (self.createSessionBlocks) {
        DConnectEventSession *session = self.createSessionBlocks(request, serviceId, receiverId, plugin.pluginId);
        [table add: session];
        
        if ([plugin.pluginVersionName isEqualToString: [V100 toString]]) {
            [request setSessionKey: [DConnectEventProtocol createSessionKeyForPlugin: session]];
        }
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

+ (DConnectEventProtocol *) getInstance: (/*DConnectMessageService * */DConnectManager *) context
                                request: (DConnectRequestMessage *) request {
    
    // request.getStringExtra(DConnectService.EXTRA_INNER_TYPE);
    NSString *appType = [request stringForKey: DConnectServiceInnerType];
    
    if ([appType isEqualToString: DConnectServiceInnerTypeHttp]) {   // DConnectService.INNER_TYPE_HTTP
        
        // [Android]
        // return new EventProtocol(context)
        // @Override EventSession createSession(Intent request, String serviceId, String receiverId, String pluginId) { ... }
        CreateSessionBlocks blocks = ^(DConnectRequestMessage *request, NSString *serviceId, NSString *receiverId, NSString *pluginId) {
            
            NSString *accessToken = request.accessToken;
            NSString *profileName = request.profile;
            NSString *interfaceName = request.interface;
            NSString *attributeName = request.attribute;
            
            DConnectEventSession *session = [DConnectEventSession new];
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
        
        return [[DConnectEventProtocol alloc] initWithContext:context
                                  createSessionBlocks: blocks];
        
    } else {
        CreateSessionBlocks blocks = ^(DConnectRequestMessage *request, NSString *serviceId, NSString *receiverId, NSString *pluginId) {
            NSString *accessToken = request.accessToken;
            NSString *profileName = request.profile;
            NSString *interfaceName = request.interface;
            NSString *attributeName = request.attribute;
            
            DConnectEventSession *session = [DConnectEventSession new];
            session.accessToken = accessToken;
            session.receiverId = receiverId;
            session.serviceId = serviceId;
            session.pluginId = pluginId;
            session.profileName = profileName;
            session.interfaceName = interfaceName;
            session.attributeName = attributeName;
            //[Android]
            // session.context = context;
            // session.broadcastReceiver = receiver;
            
            return session;
        };
        
        return [[DConnectEventProtocol alloc] initWithContext: context createSessionBlocks: blocks];
    }
}

+ (NSString *) createSessionKeyForPlugin: (DConnectEventSession *) session {
    
    NSString *separator = @".";
    
    NSMutableString *result = [NSMutableString string];
    [result appendString: session.receiverId];
    [result appendString: separator];
    [result appendString: session.pluginId];
    if ([session isKindOfClass: [DConnectEventSession class]]) {
        [result appendString:separator];
        // TODO: broadcastReceiverに相当する文字列を連結する必要があるか？
        //[Android]
//        [result appendString:[session broadcastReceiver]];
    }
    return result;
}


+ (NSString *) createReceiverId: (/*)DConnectMessageService*/DConnectManager *) messageService
                        request: (DConnectRequestMessage *) request {
    
    NSString *origin = [request stringForKey: DConnectMessageOrigin];
    if (!origin && !messageService.requiresOrigin) {
        origin = DConnectServiceAnonymousOrigin;
    }
    
    NSString *receiverId;
    NSString *sessionKey = [request sessionKey];
    if (sessionKey) {
        receiverId = sessionKey;
    } else {
        receiverId = [self md5: origin];
    }
    return receiverId;
}

+ (NSString *) md5 : (NSString *) s {
    CipherSignatureProc *md5Proc = [CipherSignatureFactory getInstance: CIPHER_SIGNATURE_KIND_MD5];
    return [md5Proc generateSignature: s];
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
    if ([plugin.pluginVersionName isEqualToString: [V100 toString]]) {
        [request setSessionKey: plugin.pluginId];
    }
    return request;
}

@end

