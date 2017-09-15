//
//  DConnectWhitelist.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectWhitelist.h"
#import "DConnectSQLiteOpenHelper.h"
#import "DConnectOriginDao.h"
#import "DConnectOriginParser.h"

NSString *const DConnectWhitelistDBName = @"__dconnect_whitelist.db";
static NSString *const DConnectWhitelistDefaultURL = @"http://localhost:80";
static NSString *const DConnectWhitelistDefaultTitle = @"Manager(HTTP)";
const int DCONNECT_WHITELIST_DB_VERSION = 1;

@interface DConnectWhitelist () <DConnectSQLiteOpenHelperDelegate>
{
    DConnectSQLiteOpenHelper *_helper;
}
@end

@implementation DConnectWhitelist

- (id) init
{
    self = [super init];
    if (self) {
        _helper = [DConnectSQLiteOpenHelper helperWithDBName:DConnectWhitelistDBName
                                                     version:DCONNECT_WHITELIST_DB_VERSION];
        _helper.delegate = self;
        DConnectSQLiteDatabase *sqlDB = [_helper database];
        [sqlDB close];
    }
    return self;
}

+ (DConnectWhitelist *) sharedWhitelist
{
    static DConnectWhitelist *sharedWhitelist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWhitelist = [[DConnectWhitelist alloc] init];
    });
    id<DConnectOrigin> origin = [DConnectOriginParser parse:DConnectWhitelistDefaultURL];
    if (![sharedWhitelist existOrigin:origin title:DConnectWhitelistDefaultTitle]) {
        [sharedWhitelist addOrigin:origin title:DConnectWhitelistDefaultTitle];
    }
    return sharedWhitelist;
}

- (NSArray *) origins
{
    NSMutableArray *result = [NSMutableArray array];
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        [result addObjectsFromArray:[DConnectOriginDao originsWithDatabase:database]];
    }];
    return result;
}

- (BOOL) allows:(id<DConnectOrigin>) origin
{
    NSArray *origins = [self origins];
    for (DConnectOriginInfo *info in origins) {
        if ([info matches:origin]) {
            return YES;
        }
    }
    return NO;
}

- (DConnectOriginInfo *) addOrigin:(id<DConnectOrigin>) origin
                             title:(NSString *)title
{
    __block DConnectOriginInfo *originInfo = nil;
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        originInfo = [DConnectOriginDao insertWithOrigin:origin
                                                   title:title
                                              toDatabase:database];
    }];
    return originInfo;
}

- (void) updateOrigin:(DConnectOriginInfo *) info
{
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        [DConnectOriginDao updateWithOriginInfo:info
                                     onDatabase:database];
    }];
}
- (BOOL) existOrigin:(id<DConnectOrigin>) origin
               title:(NSString *)title
{
    NSMutableArray *result = [NSMutableArray array];
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        [result addObjectsFromArray:[DConnectOriginDao queryWithOrigin:origin
                                                                 title:title
                                                            toDatabase:database]];
    }];
    return [result count] > 0;
}
- (void) removeOrigin:(DConnectOriginInfo *) info
{
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        if (!database) {
            return;
        }
        [DConnectOriginDao deleteWithOriginInfo:info
                                     onDatabase:database];
    }];
}

#pragma mark - DConnectSQLiteOpenHelperDelegate

- (void) openHelper:(DConnectSQLiteOpenHelper *)helper didCreateDatabase:(DConnectSQLiteDatabase *)database {
    @try {
        [DConnectOriginDao createWithDatabase:database];
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

@end
