//
//  DConnectServiceManager.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceManager.h"
#import "DConnectApiSpecList.h"
#import "DConnectMessage.h"

/**
 ServiceManagerインスタンスを格納する(key:クラス名(NSString*),
 value:インスタンス(DConnectServiceManager*))
 */
static NSMutableDictionary *_instanceArray = nil;



@interface DConnectServiceManager() {
    
    /** キー(クラス名) */
    NSString *_key;
}

// DConnectApiSpecの配列
@property NSMutableArray *mApiSpecList;

@property DConnectApiSpecList *mApiSpecs;

// key: NSString, value:DConnectService のdictionary
@property NSMutableDictionary *mDConnectServices;

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
    self.mApiSpecs = dictionary;
}

/*
- (void) addService: (DConnectService *) service {
    NSLog(@"addService: id = %@", [service serviceId);
    
    if (self.mApiSpecs) {
        for(DConnectProfile *profile in [service profileList]) {
            for(DConnectApi *api in [profile apiList]) {
                NSString *path = [self createPath: [profile profileName] api: api];
                DConnectApiSpec *spec = [mApiSpecs findApiSpec: [DConnectApi convertMethodToString: [api method]] path: path];
                if (spec) {
                    [api setApiSpec: spec];
                }
            }
        }
    }
    
    mDConnectServices[[service serviceId] = service;
    
    NSLog(@"mDConnectServices.size = %d", [mDConnectServices count]);
}
*/

/*
- (NSString *) createPath:(NSString *) profileName api:(DConnectApi *) api {
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
*/
/*
- (void) removeService: (NSString *) serviceId {
    [self.mDConnectServices remove: serviceId];
}
*/

/*
//@Override
- (DConnectService *) service: (NSString *) serviceId {
    return mDConnectServices[serviceId];
}
*/

/*
//@Override
// DConnectServiceの配列を返す
- (NSArray *) serviceList {
    NSLog(@"getServiceList: %d", [self.mDConnectServices count]);
    
    // ディープコピー
    // TODO: DConnectServiceはディープコピー対応する(NSCopyingを実装する)
    
    NSArray *list = [[NSArray alloc] initWithArray:[self.mDConnectServices allValues] copyItems: YES];
    return list;
}
*/

/*
- (BOOL) hasService: (NSString *)serviceId {
    return [self service: serviceId];
}
*/

@end
