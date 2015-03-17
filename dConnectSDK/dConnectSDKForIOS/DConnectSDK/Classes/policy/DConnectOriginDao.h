//
//  DConnectOriginDao.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSQLite.h"
#import "DConnectOriginInfo.h"

#define DCEForm(...) [NSString stringWithFormat:__VA_ARGS__]

@interface DConnectOriginDao : NSObject

+ (void) createWithDatabase:(DConnectSQLiteDatabase *)database;

+ (NSArray *) originsWithDatabase:(DConnectSQLiteDatabase *)database;

+ (DConnectOriginInfo *) insertWithOrigin:(id<DConnectOrigin>)origin
                                    title:(NSString *)title
                               toDatabase:(DConnectSQLiteDatabase *)database;

+ (void) updateWithOriginInfo:(DConnectOriginInfo *) info
                   onDatabase:(DConnectSQLiteDatabase *)database;

+ (void) deleteWithOriginInfo:(DConnectOriginInfo *)info
                   onDatabase:(DConnectSQLiteDatabase *)database;

@end