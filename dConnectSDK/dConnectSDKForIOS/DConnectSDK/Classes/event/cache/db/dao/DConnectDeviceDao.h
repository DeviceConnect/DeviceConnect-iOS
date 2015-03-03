//
//  DConnectDeviceDao.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSQLite.h"

extern NSString *const DConnectDeviceDaoTableName;
extern NSString *const DConnectDeviceDaoClmServiceId;

extern NSString *const DConnectDeviceDaoEmptyServiceId;

@interface DConnectDeviceDao : NSObject

+ (void) createWithDatabase:(DConnectSQLiteDatabase *)database;
+ (long long) insertWithServiceId:(NSString *)serviceId toDatabase:(DConnectSQLiteDatabase *)database;

@end
