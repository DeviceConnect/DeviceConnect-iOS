//
//  DConnectDBCacheController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDBCacheController.h"
#import "DConnectSQLite.h"
#import "DConnectEventDaoHeader.h"

#define DCONNECT_EVENT_DB_VERSION 1

NSString *const DConnectDBCacheControllerDBName = @"__dconnect_event.db";

@interface DConnectDBCacheController()<DConnectSQLiteOpenHelperDelegate> {
    NSString *_key;
    DConnectSQLiteOpenHelper *_helper;
}

@end

@implementation DConnectDBCacheController

#pragma mark - initialize
- (id) init {
    // 引数無しで初期化されたくないのでnilを返す。
    return nil;
}

- (id) initWithClass:(Class)clazz {
    return [self initWithKey:NSStringFromClass(clazz)];
}

- (id) initWithKey:(NSString *)key {
    self = [super init];
    
    if (self) {
        _key = key;
        NSString *name = [NSString stringWithFormat:@"%@%@", key, DConnectDBCacheControllerDBName];
        _helper = [DConnectSQLiteOpenHelper helperWithDBName:name version:DCONNECT_EVENT_DB_VERSION];
        _helper.delegate = self;
        // databaseを呼び出すとDBを作成するのでここで作成しておく。
        DConnectSQLiteDatabase *sqlDB = [_helper database];
        [sqlDB close];
    }
    
    return self;
}

#pragma mark - DConnectEventCacheController

- (DConnectEventError) addEvent:(DConnectEvent *)event {
    
    if (![self checkParameterOfEvent:event]) {
        return DConnectEventErrorInvalidParameter;
    }
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            long long pId = [DConnectProfileDao insertWithName:event.profile toDatabase:database];
            if (pId <= 0) {
                break;
            }
            
            long long iId = [DConnectInterfaceDao insertWithName:event.interface
                                                       profileId:pId toDatabase:database];
            if (iId <= 0) {
                break;
            }
            
            long long aId = [DConnectAttributeDao insertWithName:event.attribute
                                                     interfaceId:iId toDatabase:database];
            if (aId <= 0) {
                break;
            }
            
            long long dId = [DConnectDeviceDao insertWithServiceId:event.serviceId toDatabase:database];
            if (dId <= 0) {
                break;
            }
            
            long long edId = [DConnectEventDeviceDao insertWithAttributeId:aId
                                                                  serviceId:dId toDatabase:database];
            if (edId <= 0) {
                break;
            }
            
            long long cId = [DConnectClientDao insertWithEvent:event toDatabase:database];
            if (cId <= 0) {
                break;
            }
            
            long long esId = [DConnectEventSessionDao insertWithEventServiceId:edId
                                                                     clientId:cId
                                                                   toDatabase:database];
            if (esId <= 0) {
                break;
            }
            result = DConnectEventErrorNone;
            
        } while (false);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return result;
}

- (DConnectEventError) removeEvent:(DConnectEvent *)event {
    
    if (![self checkParameterOfEvent:event]) {
        return DConnectEventErrorInvalidParameter;
    }
    
    __block DConnectEventError error = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        
        [database beginTransaction];
        error = [DConnectEventSessionDao deleteEvent:event onDatabase:database];
        if (error == DConnectEventErrorNone || error == DConnectEventErrorNotFound) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return error;
}

- (BOOL) removeEventsForOrigin:(NSString *)origin {
    
    __block BOOL result = false;
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            NSArray *clients = [DConnectClientDao clientsForOrigin:origin
                                                            onDatabase:database];
            if (!clients) {
                break;
            } else if (clients.count == 0) {
                result = true;
                break;
            }
            
            NSMutableArray *ids = [NSMutableArray array];
            for (DConnectClient *client in clients) {
                [ids addObject:[NSNumber numberWithLongLong:client.rowId]];
            }
            
            DConnectEventError error = [DConnectEventSessionDao deleteWithIds:ids
                                                                   onDatabase:database];
            if (error == DConnectEventErrorFailed
                || error == DConnectEventErrorInvalidParameter)
            {
                break;
            }
            
            result = true;
            
        } while (false);
        
        if (result) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return result;
}

- (BOOL) removeAll {
    
    __block BOOL result = false;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        
        [database beginTransaction];
        NSArray *tables = @[DConnectEventDeviceDaoTableName, DConnectAttributeDaoTableName,
                            DConnectInterfaceDaoTableName, DConnectProfileDaoTableName,
                            DConnectClientDaoTableName, DConnectDeviceDaoTableName];
        
        for (NSString *table in tables) {
            int count = [database deleteFromTable:table where:nil bindParams:nil];
            if (count < 0) {
                [database rollback];
                return;
            }
        }
        
        [database commit];
        result = true;
    }];
    
    
    return result;
}


- (DConnectEvent *) eventForServiceId:(NSString *)serviceId profile:(NSString *)profile
                           interface:(NSString *)interface attribute:(NSString *)attribute
                          origin:(NSString *)origin
{
    
    __block DConnectEvent *event = nil;
    __block DConnectDBCacheController *_self = self;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        DConnectEvent *search = [DConnectEvent new];
        search.serviceId = serviceId;
        search.profile = profile;
        search.interface = interface;
        search.attribute = attribute;
        search.origin = origin;
        
        if (![_self checkParameterOfEvent:search]) {
            return;
        }
        
        DConnectEventSessionData *data = [DConnectEventSessionDao eventSessionForEvent:search
                                                                        onDatabase:database];
        if (!data) {
            return;
        }
    
        DConnectClient *client = [DConnectClientDao clientWithId:data.cId
                                                      onDatabase:database];
        if (!client) {
            return;
        }
        
        search.accessToken = client.accessToken;
        search.createDate = data.createDate;
        search.updateDate = data.updateDate;
        
        event = search;
        
    }];
    
    return event;
}

- (NSArray *) eventsForServiceId:(NSString *)serviceId profile:(NSString *)profile
                      interface:(NSString *)interface attribute:(NSString *)attribute
{
    
    NSMutableArray *result = [NSMutableArray array];
    __block DConnectDBCacheController *_self = self;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        DConnectEvent *search = [DConnectEvent new];
        search.serviceId = serviceId;
        search.profile = profile;
        search.interface = interface;
        search.attribute = attribute;
        search.origin = @"dummy";
        
        if (![_self checkParameterOfEvent:search]) {
            return;
        }
        
        NSArray *clients = [DConnectClientDao clientsForAPIWithServiceId:search onDatabase:database];
        if (!clients) {
            return;
        }
        
        for (DConnectClient *client in clients) {
            DConnectEvent *event = [DConnectEvent new];
            event.serviceId = serviceId;
            event.profile = profile;
            event.interface = interface;
            event.attribute = attribute;
            event.origin = client.origin;
            event.accessToken = client.accessToken;
            event.createDate = client.esCreateDate;
            event.updateDate = client.esUpdateDate;
            [result addObject:event];
        }
    }];
    
    return result;
}

- (void) flush {
}

#pragma mark - DConnectSQLiteOpenHelperDelegate

- (void) openHelper:(DConnectSQLiteOpenHelper *)helper didCreateDatabase:(DConnectSQLiteDatabase *)database {
    
    @try {
        [DConnectProfileDao createWithDatabase:database];
        [DConnectInterfaceDao createWithDatabase:database];
        [DConnectAttributeDao createWithDatabase:database];
        [DConnectClientDao createWithDatabase:database];
        [DConnectDeviceDao createWithDatabase:database];
        [DConnectEventDeviceDao createWithDatabase:database];
        [DConnectEventSessionDao createWithDatabase:database];
    }
    @catch (NSString *exception) {
        
        // 本来は上で閉じるがエラーを投げるのでとりあえず閉じておく。
        [database close];
        
        // 作成に失敗したらDBを削除。
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *path = paths[0];
        NSString *dbFilePath = [path stringByAppendingPathComponent:database.dbName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:dbFilePath error:nil];
        
        @throw @"ERROR: Could not create DB.";
    }
}

- (void) openHelper:(DConnectSQLiteOpenHelper *)helper didUpgradeDatabase:(DConnectSQLiteDatabase *)database
         oldVersion:(int)oldVersion
         newVersion:(int)newVersion
{
    // バージョン1なので特に処理無し。バージョンの変更がある場合は要対応。
    
}

#pragma mark - static

+ (DConnectDBCacheController *) controllerWithClass:(Class)clazz {
    return [[DConnectDBCacheController alloc] initWithClass:clazz];
}

+ (DConnectDBCacheController *) controllerWithKey:(NSString *)key {
    return [[DConnectDBCacheController alloc] initWithKey:key];
}

@end
