//
//  DPHitoeDBManager.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeDBManager.h"
#import "DPHitoeConsts.h"


NSString *const DPHitoeDeviceDB = @"HitoeDevice";

NSString *const DPHitoeColumnType = @"type";
NSString *const DPHitoeColumnServiceId = @"serviceId";
NSString *const DPHitoeColumnRegisterFlag = @"registerFlag";
NSString *const DPHitoeColumnPinCode = @"pinCode";
NSString *const DPHitoeColumnName = @"name";
NSString *const DPHitoeColumnConnectMode = @"connectMode";

@implementation DPHitoeDBManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - init

+ (DPHitoeDBManager *)sharedInstance {
    static DPHitoeDBManager *instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [DPHitoeDBManager new];
    });
    return instance;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        [self loadManagedObjectContext];
    }
    
    return self;
}

- (void) loadManagedObjectContext {
    
    if (_managedObjectContext != nil)
        return;
    
    NSPersistentStoreCoordinator *aCoodinator = [self coordinator];
    if (aCoodinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:aCoodinator];
    }
}


- (NSPersistentStoreCoordinator *)coordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory]  URLByAppendingPathComponent: @"DPHitoeTable.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator
          addPersistentStoreWithType:NSSQLiteStoreType
          configuration:nil
          URL:storeURL
          options:nil
          error:&error]) {
        abort();
    }
    
    return _persistentStoreCoordinator;
}
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *modelPath = [DPHitoeBundle() pathForResource:@"DPHitoeTable"ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - CRUD


- (BOOL)insertHitoeDevice:(DPHitoeDevice *)device {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:DPHitoeDeviceDB
                                                            inManagedObjectContext:_managedObjectContext];
    
    [object setValue:device.type forKey:DPHitoeColumnType];
    [object setValue:device.name forKey:DPHitoeColumnName];
    [object setValue:device.serviceId forKey:DPHitoeColumnServiceId];
    [object setValue:device.connectMode forKey:DPHitoeColumnConnectMode];
    [object setValue:device.pinCode forKey:DPHitoeColumnPinCode];
    [object setValue:[NSNumber numberWithBool:device.registerFlag] forKey:DPHitoeColumnRegisterFlag];

    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        return NO;
    }
    return YES;
}

- (NSMutableArray*)queryHitoDeviceWithServiceId:(NSString * )serviceId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSMutableArray *devices = [NSMutableArray new];

    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPHitoeDeviceDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPHitoeColumnName ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *pred = nil;
    if (serviceId) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@", DPHitoeColumnServiceId, serviceId];
    }
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        return devices;
    }
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    for (int i = 0; i < moArray.count; i++) {
        DPHitoeDevice* device = [[DPHitoeDevice alloc] initWithInfoString:nil];
        NSManagedObject *object = [moArray objectAtIndex:i];
        device.serviceId= [object valueForKey:DPHitoeColumnServiceId];
        device.name = [object valueForKey:DPHitoeColumnName];
        device.type = [object valueForKey:DPHitoeColumnType];
        device.pinCode = [object valueForKey:DPHitoeColumnPinCode];
        device.connectMode = [object valueForKey:DPHitoeColumnConnectMode];
        device.registerFlag = [[object valueForKey:DPHitoeColumnRegisterFlag] boolValue];
        [devices addObject:device];
    }
    return devices;
}

- (BOOL)updateHitoeDevice:(DPHitoeDevice *)device  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPHitoeDeviceDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPHitoeColumnName ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *pred = nil;
    if (device) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@",
                DPHitoeColumnServiceId, device.serviceId];
    } else {
        return NO;
    }
    [fetchRequest setPredicate:pred];
    
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        return NO;
    }
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    if (moArray.count <= 0) {
        return NO;
    }
    NSManagedObject *upObject = [moArray objectAtIndex:0];
    [upObject setValue:device.type forKey:DPHitoeColumnType];
    [upObject setValue:device.name forKey:DPHitoeColumnName];
    [upObject setValue:device.serviceId forKey:DPHitoeColumnServiceId];
    [upObject setValue:device.connectMode forKey:DPHitoeColumnConnectMode];
    [upObject setValue:device.pinCode forKey:DPHitoeColumnPinCode];
    [upObject setValue:[NSNumber numberWithBool:device.registerFlag] forKey:DPHitoeColumnRegisterFlag];
    if (![_managedObjectContext save:&error]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteHitoeDeviceWithServiceId:(NSString *)serviceId  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPHitoeDeviceDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPHitoeColumnName ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *pred = nil;
    if (serviceId) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@", DPHitoeColumnServiceId, serviceId];
    } else {
        return NO;
    }
    [fetchRequest setPredicate:pred];
    
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        return NO;
    }
    
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    if (moArray.count <= 0) {
        return NO;
    }
    for (int i = 0; i < [moArray count]; i++) {
        NSManagedObject *object = [moArray objectAtIndex:i];
        [_managedObjectContext deleteObject:object];
    }
    if (![_managedObjectContext save:&error]) {
        return NO;
    }
    return YES;
}


@end
