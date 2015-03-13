//
//  DConnectOriginDao.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOriginDao.h"
#import "DConnectOriginInfo.h"
#import "DConnectOriginParser.h"

NSString *const DConnectOriginDaoTableName = @"Origin";
NSString *const DConnectOriginDaoClmId = @"o_id";
NSString *const DConnectOriginDaoClmOrigin = @"origin";
NSString *const DConnectOriginDaoClmTitle = @"title";
NSString *const DConnectOriginDaoClmDate = @"date";

@implementation DConnectOriginDao

+ (void) createWithDatabase:(DConnectSQLiteDatabase *)database
{
    NSString *sql = DCEForm(@"CREATE TABLE %@ "
                            "(%@ INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "%@ TEXT NOT NULL, %@ TEXT NOT NULL, "
                            "%@ INTEGER NOT NULL,"
                            "UNIQUE(%@));",
                            DConnectOriginDaoTableName,
                            DConnectOriginDaoClmId,
                            DConnectOriginDaoClmOrigin,
                            DConnectOriginDaoClmTitle,
                            DConnectOriginDaoClmDate,
                            DConnectOriginDaoClmId);
    
    if (![database execSQL:sql]) {
        @throw @"error";
    }
}

+ (NSArray *) originsWithDatabase:(DConnectSQLiteDatabase *)database
{
    NSString *sql = DCEForm(@"SELECT %@, %@, %@, %@ FROM %@",
                            DConnectOriginDaoClmId,
                            DConnectOriginDaoClmOrigin,
                            DConnectOriginDaoClmTitle,
                            DConnectOriginDaoClmDate,
                            DConnectOriginDaoTableName);
    DConnectSQLiteCursor *cursor = [database queryWithSQL:sql];
    NSMutableArray *result = [NSMutableArray array];
    if ([cursor moveToFirst]) {
        do {
            DConnectOriginInfo *info = [DConnectOriginInfo new];
            info.rowId = [cursor longLongValueAtIndex:0];
            info.origin = [DConnectOriginParser parse:[cursor stringValueAtIndex:1]];
            info.title = [cursor stringValueAtIndex:2];
            info.date = [cursor longLongValueAtIndex:3];
            [result addObject:info];
        } while ([cursor moveToNext]);
    }
    [cursor close];
    return result;
}

+ (DConnectOriginInfo *) insertWithOrigin:(id<DConnectOrigin>)origin
                                    title:(NSString *)title
                               toDatabase:(DConnectSQLiteDatabase *)database
{
    [database beginTransaction];
    long long current = (long long) [[NSDate date] timeIntervalSince1970];
    long long result = [database insertIntoTable:DConnectOriginDaoTableName
                                         columns:@[DConnectOriginDaoClmOrigin,
                                                   DConnectOriginDaoClmTitle,
                                                   DConnectOriginDaoClmDate]
                                          params:@[[origin stringify],
                                                   title,
                                                   [NSNumber numberWithLongLong:current]]];
    if (result != -1) {
        [database commit];
        DConnectOriginInfo *info = [DConnectOriginInfo new];
        info.rowId = result;
        info.origin = origin;
        info.title = title;
        info.date = current;
        return info;
    } else {
        [database rollback];
        @throw @"error";
    }
}

+ (void) updateWithOriginInfo:(DConnectOriginInfo *) info
                   onDatabase:(DConnectSQLiteDatabase *)database
{
    [database beginTransaction];
    NSNumber *current = [NSNumber numberWithLongLong:(long long) [[NSDate date] timeIntervalSince1970]];
    int result = [database updateTable:DConnectOriginDaoTableName
                               columns:@[DConnectOriginDaoClmOrigin,
                                         DConnectOriginDaoClmTitle,
                                         DConnectOriginDaoClmDate]
                                 where:DCEForm(@"%@=?", DConnectOriginDaoClmId)
                            bindParams:@[[info.origin stringify],
                                         info.title,
                                         current,
                                         [NSNumber numberWithLongLong:info.rowId]]];
    if (result == 1) {
        [database commit];
    } else {
        [database rollback];
        @throw @"error";
    }
}

+ (void) deleteWithOriginInfo:(DConnectOriginInfo *)info
                   onDatabase:(DConnectSQLiteDatabase *)database
{
    [database beginTransaction];
    int result = [database deleteFromTable:DConnectOriginDaoTableName
                                     where:DCEForm(@"%@=?", DConnectOriginDaoClmId)
                                bindParams:@[[NSNumber numberWithLongLong:info.rowId]]];
    if (result == 1) {
        [database commit];
    } else {
        [database rollback];
        @throw @"error";
    }
}

@end