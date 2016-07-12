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
#import "DConnectApiSpecList.h"

/**
 ServiceManagerインスタンスを格納する(key:クラス名(NSString*),
 value:インスタンス(DConnectServiceManager*))
 */
static NSMutableDictionary *_instanceArray = nil;



@interface DConnectServiceManager() {
    
    /** キー(クラス名) */
    NSString *_key;
}

@end


@implementation DConnectServiceManager


+ (DConnectServiceManager *)sharedForClass: (Class)clazz {
    
    NSString *key = [clazz description];
    NSLog(@"[DConnectServiceManager sharedForClass: %@]", key);
    
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
        self.mApiSpecList = nil;
        self.mApiSpecs = nil;
        self.mDConnectServices = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) setApiSpecDictionary: (DConnectApiSpecList *) dictionary {
    _mApiSpecs = dictionary;
}


#pragma mark - DConnectServiceProvider Implement.

- (void) addService: (DConnectService *) service {
    
    NSString *serviceId = [service serviceId];
    
    NSLog(@"addService: id = %@", serviceId);
    
    if (_mApiSpecs) {
        
        for (DConnectProfile *profile in [service profiles]) {
            for (DConnectApi *api in [profile apis]) {
                NSString *path = [self createPath: [profile profileName] api: api];
                
                NSString *strMethod = [DConnectApiSpec convertMethodToString: [api method]];
                DConnectApiSpec *spec = [_mApiSpecs findApiSpec: strMethod path: path];
                if (spec) {
                    [api setApiSpec: spec];
                }
            }
        }
    }
    
    _mDConnectServices[serviceId] = service;
}

- (void) removeService: (DConnectService *) service {
    NSString *serviceId = [service serviceId];
    [_mDConnectServices removeObjectForKey: serviceId];
}

- (DConnectService *) service: (NSString *) serviceId {
    return _mDConnectServices[serviceId];
}

- (NSArray *) services {
    NSLog(@"getServices: %d", (int)[_mDConnectServices count]);
    NSMutableArray *list = [NSMutableArray array];
    [list addObjectsFromArray: [_mDConnectServices allValues]];
    return list;
}

- (void) removeAllServices {
    [_mDConnectServices removeAllObjects];
}

- (BOOL) hasService: (NSString *) serviceId {
    if ([self service: serviceId]) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods.

- (NSString *) createPath: (NSString *) profileName api: (DConnectApi *) api {
    NSString *interfaceName = [api interface];
    NSString *attributeName = [api attribute];
    NSMutableString *path = [NSMutableString string];
    [path appendString: @"/"];
    [path appendString: DConnectMessageDefaultAPI];
    [path appendString: @"/"];
    [path appendString: profileName];
    if (interfaceName) {
        [path appendString: @"/"];
        [path appendString: interfaceName];
    }
    if (attributeName) {
        [path appendString: @"/"];
        [path appendString: attributeName];
    }
    return path;
}

@end
