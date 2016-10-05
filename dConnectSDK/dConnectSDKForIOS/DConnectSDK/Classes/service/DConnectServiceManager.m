//
//  DConnectServiceManager.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceManager.h>
#import <DConnectSDK/DConnectProfile.h>
#import <DConnectSDK/DConnectApiEntity.h>

/**
 ServiceManagerインスタンスを格納する(key:クラス名(NSString*),
 value:インスタンス(DConnectServiceManager*))
 */
static NSMutableDictionary *_instanceArray = nil;



@interface DConnectServiceManager() {
    
    /*!
     @brief キー(クラス名)
     */
    NSString *_key;
    
    /*!
     @brief 接続サービス配列(key:サービスID value: DConnectService *)]
     */
    NSMutableDictionary *mDConnectServices;
    
}

@property(nonatomic, weak) id plugin_;

@property(nonatomic, strong) NSMutableArray<__kindof id<DConnectServiceListener>> *serviceListeners;

@end


@implementation DConnectServiceManager


+ (DConnectServiceManager *)sharedForClass: (Class)clazz {
    
    NSString *key = [clazz description];
    
    DConnectServiceManager *manager = [DConnectServiceManager sharedForKey: key];
    return manager;
}

+ (DConnectServiceManager *)sharedForKey: (NSString *)key {
    
    /* mInstanceArray初期化 */
    if (_instanceArray == nil) {
        _instanceArray = [NSMutableDictionary dictionary];
    }
    
    DConnectServiceManager *instance = _instanceArray[key];
    if (instance != nil) {
        /* classに対応するインスタンスが存在すればそれを返す */
        return instance;
        
    }
    /* classに対応するインスタンスが無ければインスタンス作成して追加する */
    instance = [[DConnectServiceManager alloc] initWithKey: key];
    _instanceArray[key] = instance;
    return instance;
}

- (instancetype) initWithKey: (NSString *)key {
    self = [super init];
    
    _key = key;
    
    /* デフォルト値を設定 */
    if (self) {
        mDConnectServices = [NSMutableDictionary dictionary];
        self.serviceListeners = [NSMutableArray array];
    }
    return self;
}

#pragma mark - DConnectServiceProvider Implement.

- (id) plugin {
    return [self plugin_];
}

- (void) setPlugin: (id) plugin {
    [self setPlugin_: plugin];
}

- (void) addService: (DConnectService *) service bundle:(NSBundle *) selfBundle {
    
    NSString *serviceId = [service serviceId];
    
    [service setStatusListener: self];
    
    for (DConnectProfile *profile in [service profiles]) {

        // プロファイルのJSONファイルを読み込み、内部生成したprofileSpecを新規登録する
        if (![[DConnectPluginSpec shared] findProfileSpec: [[profile profileName] lowercaseString]]) {
            NSError *error = nil;
            [[DConnectPluginSpec shared] addProfileSpec: [[profile profileName] lowercaseString] bundle: selfBundle error: &error];
            if (error) {
                DCLogE(@"addService error ! %@", [error description]);
            }
        }
        
        DConnectProfileSpec *profileSpec = [[DConnectPluginSpec shared] findProfileSpec: [[profile profileName] lowercaseString]];
        if (!profileSpec) {
            continue;
        }
        [profile setProfileSpec: profileSpec];
        for (DConnectApiEntity *api in [profile apis]) {
            DConnectSpecMethod method;
            NSError *error;
            if (![DConnectSpecConstants parseMethod:[api method] outMethod: &method error:&error]) {
                DCLogW(@"addService error, %@", [error description]);
                continue;
            }
            DConnectApiSpec *spec = [profileSpec findApiSpec: [api path] method: method];
            if (spec) {
                [api setApiSpec: spec];
            }
        }
    }
    
    mDConnectServices[serviceId] = service;
    
    [self notifyOnServiceAdded: service];
}

- (void) removeService: (DConnectService *) service {
    NSString *serviceId = [service serviceId];
    if (mDConnectServices[serviceId]) {
        [mDConnectServices removeObjectForKey: serviceId];
        [self notifyOnServiceRemoved: service];
    }
}

- (void) onStatusChange: (DConnectService *) service {
    [self notifyOnStatusChange: service];
}

- (DConnectService *) service: (NSString *) serviceId {
    return mDConnectServices[serviceId];
}

- (NSArray *) services {
    
    NSMutableArray *list = [NSMutableArray array];
    [list addObjectsFromArray: [mDConnectServices allValues]];
    return list;
}

- (void) removeAllServices {
    [mDConnectServices removeAllObjects];
}

- (BOOL) hasService: (NSString *) serviceId {
    if ([self service: serviceId]) {
        return YES;
    }
    return NO;
}

- (void) addServiceListener: (id<DConnectServiceListener>) listener {
    @synchronized(self.serviceListeners) {
        if (![self.serviceListeners containsObject: listener]) {
            [self.serviceListeners addObject:listener];
        }
    }
}

- (void) removeServiceListener: (id<DConnectServiceListener>) listener {
    @synchronized(self.serviceListeners) {
        [self.serviceListeners removeObject:listener];
    }
}

#pragma mark - OnStatusChangeListener Methods.

- (void)didStatusChange:(DConnectService *)service {
    [self notifyOnStatusChange: service];
}

#pragma mark - private methods.

- (void) notifyOnServiceAdded: (DConnectService *) service {
    @synchronized (self.serviceListeners) {
        for (id<DConnectServiceListener> l in self.serviceListeners) {
            [l didServiceAdded: service];
        }
    }
}

- (void) notifyOnServiceRemoved: (DConnectService *) service {
    @synchronized (self.serviceListeners) {
        for (id<DConnectServiceListener> l in self.serviceListeners) {
            [l didServiceRemoved: service];
        }
    }
}

- (void) notifyOnStatusChange: (DConnectService *) service {
    @synchronized (self.serviceListeners) {
        for (id<DConnectServiceListener> l in self.serviceListeners) {
            [l didStatusChange: service];
        }
    }
}

@end
