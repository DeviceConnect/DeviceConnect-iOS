//
//  DConnectManagerSystemProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManagerSystemProfile.h"
#import "DConnectManager+Private.h"
#import "DConnectManager.h"

@implementation DConnectManagerSystemProfile

- (BOOL) didReceiveRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response {
    NSUInteger action = [request integerForKey:DConnectMessageAction];
    BOOL send = NO;
    
    if (action == DConnectMessageActionTypeGet) {
        send = [self didReceiveGetRequest:request response:response];
    } else if (action == DConnectMessageActionTypePut) {
        send = [self didReceivePutRequest:request response:response];
    } else if (action == DConnectMessageActionTypePost) {
        send = [self didReceivePostRequest:request response:response];
    } else if (action == DConnectMessageActionTypeDelete) {
        send = [self didReceiveDeleteRequest:request response:response];
    }
    
    return send;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
{
    NSString *attribute = [request attribute];
    NSString *interface = [request interface];
    
    BOOL send = NO;
    if (attribute == nil && interface == nil) {
        send = [self didReceiveGetSystemRequest:request response:response];
    } else if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrKeyword] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        send = YES;
    } else if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrEvents] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        send = YES;
    }
    return send;
}


- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
{
    NSString *attribute = [request attribute];
    NSString *interface = [request interface];
    if (interface == nil && attribute == nil) {
        [response setErrorToNotSupportAction];
        return YES;
    } else if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrKeyword] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        return YES;
    } else  if (attribute && [attribute localizedCaseInsensitiveCompare:DConnectSystemProfileAttrEvents] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        return YES;
    }
    // 属性やインターフェースが存在する場合には、
    // 未処理扱いにして各デバイスプラグインに配送する
    return NO;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
{
    NSString *attribute = [request attribute];
    NSString *interface = [request interface];
    if (interface == nil && attribute == nil) {
        [response setErrorToNotSupportAction];
        return YES;
    } else if (attribute && [attribute localizedCaseInsensitiveCompare:DConnectSystemProfileAttrKeyword] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        return YES;
    } else  if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrEvents] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        return YES;
    }
    // 属性やインターフェースが存在する場合には、
    // 未処理扱いにして各デバイスプラグインに配送する
    return NO;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    NSString *attribute = [request attribute];
    NSString *interface = [request interface];
    if (interface == nil && attribute == nil) {
        [response setErrorToNotSupportAction];
        return YES;
    } else if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrKeyword] == NSOrderedSame) {
        [response setErrorToNotSupportAction];
        return YES;
    } else if (attribute && [attribute localizedCaseInsensitiveCompare: DConnectSystemProfileAttrEvents] == NSOrderedSame) {
        NSString *sessionKey = [request sessionKey];
        return [self profile:self didReceiveDeleteEventsRequest:request
                    response:response
                  sessionKey:sessionKey];
    }
    // 属性やインターフェースが存在する場合には、
    // 未処理扱いにして各デバイスプラグインに配送する
    return NO;
}

- (BOOL) didReceiveGetSystemRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
{
    // DConnectManagerのシステムプロファイルを作成
    DConnectManager *mgr = (DConnectManager *) self.provider;
    DConnectDevicePluginManager *pluginMgr = mgr.mDeviceManager;
    
    NSArray *profiles = [mgr profiles];
    NSArray *deviceplugins = [pluginMgr devicePluginList];
    
    // サポートするプロファイル一覧
    DConnectArray *supports = [DConnectArray array];
    for (DConnectProfile *plugin in profiles) {
        [supports addString:[plugin profileName]];
    }
    
    // デバイスプラグイン一覧
    DConnectArray *plugins = [DConnectArray array];
    for (DConnectDevicePlugin *plugin in deviceplugins) {
        DConnectMessage *message = [DConnectMessage new];
        NSString *className = NSStringFromClass([plugin class]);
        NSString *pluginId = [NSString stringWithFormat:@"%@.dconnect", className];
        NSString *pluginName = [plugin pluginName];
        NSString *versionName = [plugin pluginVersionName];
        [message setString:pluginId forKey:DConnectSystemProfileParamId];
        [message setString:pluginName forKey:DConnectSystemProfileParamName];
        [message setString:versionName forKey:DConnectSystemProfileParamVersion];
        DConnectArray *profileNames = [DConnectArray new];
        NSArray *profiles = [plugin profiles];
        for (DConnectProfile *profile in profiles) {
            [profileNames addString:[profile profileName]];
            if (profile.profileName && [profile.profileName localizedCaseInsensitiveCompare:@"system"] == NSOrderedSame) {
                DConnectSystemProfile *sysProfile = (DConnectSystemProfile *) profile;
                if (sysProfile.dataSource) { //バージョンに変更がある場合は、各プラグインで変更する
                    DConnectDevicePlugin *devicePlugin = [pluginMgr devicePluginForPluginId:className];
                    [message setString:devicePlugin.pluginVersionName forKey:DConnectSystemProfileParamVersion];
                }
            }
        }
        [DConnectSystemProfile setSupports:profileNames target:message];
        [plugins addMessage:message];
    }
    
    [response setResult:DConnectMessageResultTypeOk];
    
    // Managerの名前とUUID
    [DConnectSystemProfile setName:[[DConnectManager sharedManager] managerName] target:response];
    [DConnectSystemProfile setUUID:[[DConnectManager sharedManager] managerUUID] target:response];
    
    [DConnectSystemProfile setSupports:supports target:response];
    [DConnectSystemProfile setPlugins:plugins target:response];
    return YES;
}


- (BOOL)              profile:(DConnectSystemProfile *)profile
didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                   sessionKey:(NSString *)sessionKey
{
    if (sessionKey == nil) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey is nil."];
    } else {
        DConnectManager *mgr = (DConnectManager *) self.provider;
        DConnectDevicePluginManager *pluginMgr = mgr.mDeviceManager;
        
        NSArray *deviceplugins = [pluginMgr devicePluginList];
        for (DConnectDevicePlugin *plugin in deviceplugins) {
            DConnectRequestMessage *copyRequest = [request copy];
            DConnectResponseMessage *dummyResponse = [DConnectResponseMessage message];
            
            // sessionkeyのコンバート
            NSMutableString *key = [NSMutableString stringWithString:sessionKey];
            [key appendString:@"."];
            [key appendString:NSStringFromClass([plugin class])];
            [copyRequest setString:key forKey:DConnectMessageSessionKey];
            
            // デバイスプラグインに配送
            [plugin didReceiveRequest:copyRequest response:dummyResponse];
        }
        
        [response setResult:DConnectMessageResultTypeOk];
    }
    return YES;
}


@end
