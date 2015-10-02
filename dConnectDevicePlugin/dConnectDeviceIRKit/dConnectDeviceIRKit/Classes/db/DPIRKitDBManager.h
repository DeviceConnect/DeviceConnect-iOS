//
//  DPIRKitDBManager.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"


extern NSString *const DPIRKitVirtualDeviceCreateNotification ;


@interface DPIRKitDBManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



+ (DPIRKitDBManager *) sharedInstance;
- (BOOL)insertVirtualDeviceWithData:(DPIRKitVirtualDevice *)device;
- (BOOL)insertRESTfulRequestWithDevice:(DPIRKitVirtualDevice *)device ;
- (NSArray *)queryVirtualDevice:(NSString *)serviceId;
- (NSArray *)queryRESTfulRequestByServiceId:(NSString *)serviceId
                                    profile:(NSString *)profile;
- (BOOL)updateRESTfulRequest:(DPIRKitRESTfulRequest *)request;
- (BOOL)deleteVirtualDevice:(NSString *)serviceId;
- (BOOL)deleteRESTfulRequestForServiceId:(NSString *)serviceId;

@end
