//
//  DConnectOriginDao.h
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/11.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectSQLite.h"
#import "DConnectOriginInfo.h"

#define DCEForm(...) [NSString stringWithFormat:__VA_ARGS__]

long long getCurrentTimeInMillis();

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