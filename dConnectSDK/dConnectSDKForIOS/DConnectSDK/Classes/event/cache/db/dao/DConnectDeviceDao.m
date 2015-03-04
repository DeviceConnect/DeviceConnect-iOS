//
//  DConnectDeviceDao.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDeviceDao.h"
#import "DConnectEventDao.h"

NSString *const DConnectDeviceDaoTableName = @"Device";
NSString *const DConnectDeviceDaoClmServiceId = @"service_id";

NSString *const DConnectDeviceDaoEmptyServiceId = @"";

@implementation DConnectDeviceDao

+ (void) createWithDatabase:(DConnectSQLiteDatabase *)database {
    
    NSString *sql = DCEForm(@"CREATE TABLE %@ "
                            "(%@ INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "%@ TEXT NOT NULL, %@ INTEGER NOT NULL, "
                            "%@ INTEGER NOT NULL, UNIQUE(%@));",
                            DConnectDeviceDaoTableName,
                            DConnectEventDaoClmId,
                            DConnectDeviceDaoClmServiceId,
                            DConnectEventDaoClmCreateDate,
                            DConnectEventDaoClmUpdateDate,
                            DConnectDeviceDaoClmServiceId);
    
    if (![database execSQL:sql]) {
        @throw @"error";
    }
}

+ (long long) insertWithServiceId:(NSString *)serviceId toDatabase:(DConnectSQLiteDatabase *)database {
    
    NSString* sId = (serviceId != nil) ? serviceId : DConnectDeviceDaoEmptyServiceId;
    long long result = -1;
    DConnectSQLiteCursor *cursor
    = [database selectFromTable:DConnectDeviceDaoTableName
                        columns:@[DConnectEventDaoClmId]
                          where:DCEForm(@"%@=?", DConnectDeviceDaoClmServiceId)
                     bindParams:@[sId]];
    
    if (!cursor) {
        return result;
    }
    
    if (cursor.count == 0) {
        NSNumber *current = [NSNumber numberWithLongLong:getCurrentTimeInMillis()];
        result = [database insertIntoTable:DConnectDeviceDaoTableName
                                   columns:@[DConnectDeviceDaoClmServiceId, DConnectEventDaoClmCreateDate,
                                             DConnectEventDaoClmUpdateDate]
                                    params:@[sId, current, current]];
    } else if ([cursor moveToFirst]) {
        result = [cursor longLongValueAtIndex:0];
    }
    
    [cursor close];
    
    return result;
}

@end
