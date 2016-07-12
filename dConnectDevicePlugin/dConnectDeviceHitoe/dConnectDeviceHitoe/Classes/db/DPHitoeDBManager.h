//
//  DPHitoeDBManager.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h> 
#import "DPHitoeDevice.h"

@interface DPHitoeDBManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DPHitoeDBManager*)sharedInstance;
- (BOOL)insertHitoeDevice:(DPHitoeDevice *)device;
- (NSMutableArray*)queryHitoDeviceWithServiceId:(NSString * )serviceId;
- (BOOL)updateHitoeDevice:(DPHitoeDevice *)device;
- (BOOL)deleteHitoeDeviceWithServiceId:(NSString *)serviceId;
@end
