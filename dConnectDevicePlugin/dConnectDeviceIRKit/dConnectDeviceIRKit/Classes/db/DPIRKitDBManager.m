//
//  DPIRKitDBManager.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitDBManager.h"
#import "DPIRKitConst.h"
#import "DPIRKitDialog.h"

NSString *const DPIRKitVirtualDeviceCreateNotification = @"org.deviceconnect.ios.irkit.VirtualDeviceCreate";

NSString *const DPIRKitIRURIMatchingDB = @"DPIRKitIRURIMatching";
NSString *const DPIRKitVirtualDeviceDB = @"DPIRKitVirtualDevice";
NSString *const DPIRKitID = @"id";
NSString *const DPIRKitIR = @"ir";
NSString *const DPIRKitServiceId = @"serviceId";
NSString *const DPIRKitURI = @"uri";
NSString *const DPIRKitCategoryName = @"categoryName";
NSString *const DPIRKitDeviceName = @"deviceName";
NSString *const DPIRKitMethod = @"method";
NSString *const DPIRKitName = @"name";

//サポートするプロファイル
//　ライトのON/OFF
NSString *const DPIRKitLightProfileNames[] = {@"ライト ON", @"ライト OFF"};
NSString *const DPIRKitLightProfileURIs[] = {@"/light", @"/light"};
NSString *const DPIRKitLightProfileMethods[] = {@"POST", @"DELETE"};
NSUInteger const DPIRKitLightProfileCount = 2;
// TV ON/OFF チャンネルUp/Down 音量Up/Down 放送電波切り替え(地デジ/BS/CS)
NSString *const DPIRKitTVProfileNames[] = {@"TV電源ON", @"TV電源OFF", @"チャンネル+",
                                         @"チャンネル-",@"1", @"2",
                                        @"3",@"4", @"5",
                                        @"6",@"7", @"8",
                                        @"9",@"10", @"11",
                                        @"12",@"音量+", @"音量-",
                                         @"地デジ", @"BS", @"CS"};
NSString *const DPIRKitTVProfileURIs[] = {@"/tv", @"/tv", @"/tv/channel?control=next",
                                        @"/tv/channel?control=previous",
                                        @"/tv/channel?tuning=1",
                                        @"/tv/channel?tuning=2",
                                        @"/tv/channel?tuning=3",
                                        @"/tv/channel?tuning=4",
                                        @"/tv/channel?tuning=5",
                                        @"/tv/channel?tuning=6",
                                        @"/tv/channel?tuning=7",
                                        @"/tv/channel?tuning=8",
                                        @"/tv/channel?tuning=9",
                                        @"/tv/channel?tuning=10",
                                        @"/tv/channel?tuning=11",
                                        @"/tv/channel?tuning=12",
                                        @"/tv/volume?control=up",
                                        @"/tv/volume?control=down",
                                        @"/tv/broadcastwave?select=DTV",
                                        @"/tv/broadcastwave?select=BS",
                                        @"/tv/broadcastwave?select=CS"};
NSString *const DPIRKitTVProfileMethods[] = {@"PUT", @"DELETE", @"PUT",
                                            @"PUT", @"PUT", @"PUT",
                                            @"PUT", @"PUT", @"PUT",
                                            @"PUT", @"PUT", @"PUT",
                                            @"PUT", @"PUT", @"PUT",
                                            @"PUT", @"PUT", @"PUT",
                                            @"PUT", @"PUT", @"PUT"};
NSUInteger const DPIRKitTVProfileCount = 21;


@interface DPIRKitDBManager()
@end

@implementation DPIRKitDBManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark Static Methods

+ (DPIRKitDBManager *) sharedInstance {
    
    static DPIRKitDBManager *instance;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[DPIRKitDBManager alloc] init];
    });
    
    return instance;
}


#pragma mark - Initialization

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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:aCoodinator];
    }
}


- (NSPersistentStoreCoordinator *)coordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory]  URLByAppendingPathComponent: @"DPIRKitTable.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator
          addPersistentStoreWithType:NSSQLiteStoreType
          configuration:nil
          URL:storeURL
          options:nil
          error:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *modelPath = [DPIRBundle() pathForResource:@"DPIRKitTable"ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}



#pragma mark - Insert

- (BOOL)insertVirtualDeviceWithData:(DPIRKitVirtualDevice *)device {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:DPIRKitVirtualDeviceDB
                                                            inManagedObjectContext:_managedObjectContext];
    
    [object setValue:device.serviceId   forKey:DPIRKitServiceId];
    [object setValue:device.deviceName forKey:DPIRKitDeviceName];
    [object setValue:device.categoryName forKey:DPIRKitCategoryName];
    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        DPIRLog(@"error = %@", error);
        return NO;
    }
    DPIRLog(@"Insert Completed.");
    
    NSNotification *notifiy =
    [NSNotification notificationWithName:DPIRKitVirtualDeviceCreateNotification //「NOTIFI_NAME」という名前の通知を
                                  object:nil
                                userInfo:nil];           // dicに詰め込んだ情報と共に作成する
    
    //Notification(通知)を発行する
    [[NSNotificationCenter defaultCenter] postNotification:notifiy];
    return YES;
}



- (BOOL)insertRESTfulRequestWithDevice:(DPIRKitVirtualDevice *)device {
    
    if ([device.categoryName isEqualToString:DPIRKitCategoryTV]) {
        for (int i = 0; i < DPIRKitTVProfileCount; i++) {
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:DPIRKitIRURIMatchingDB
                                                                    inManagedObjectContext:_managedObjectContext];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            [object setValue:dateStr forKey:DPIRKitID];
            [object setValue:device.serviceId   forKey:DPIRKitServiceId];
            [object setValue:DPIRKitTVProfileURIs[i] forKey:DPIRKitURI];
            [object setValue:DPIRKitTVProfileMethods[i] forKey:DPIRKitMethod];
            [object setValue:DPIRKitTVProfileNames[i] forKey:DPIRKitName];
            
            NSError *error = nil;
            if (![_managedObjectContext save:&error]) {
                DPIRLog(@"error = %@", error);
            }
        }
    } else if ([device.categoryName isEqualToString:DPIRKitCategoryLight]) {
        for (int i = 0; i < DPIRKitLightProfileCount; i++) {
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:DPIRKitIRURIMatchingDB
                                                                    inManagedObjectContext:_managedObjectContext];
            DPIRLog(@"register:%@", device.serviceId);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            [object setValue:dateStr forKey:DPIRKitID];
            [object setValue:device.serviceId   forKey:DPIRKitServiceId];
            [object setValue:DPIRKitLightProfileURIs[i] forKey:DPIRKitURI];
            [object setValue:DPIRKitLightProfileMethods[i] forKey:DPIRKitMethod];
            [object setValue:DPIRKitLightProfileNames[i] forKey:DPIRKitName];
            
            NSError *error = nil;
            if (![_managedObjectContext save:&error]) {
                DPIRLog(@"error = %@", error);
            }
        }
    } else {
        return NO;
    }
    
    

    DPIRLog(@"Insert Completed.");
    return YES;
}

#pragma mark - Query

- (NSArray *)queryVirtualDevice:(NSString *)serviceId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定します。
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPIRKitVirtualDeviceDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 一度に読み込むサイズを指定します。
    [fetchRequest setFetchBatchSize:20];
    
    // 検索結果を保持する順序を指定します。
    // ここでは、keyというカラムの値の昇順で保持するように指定しています。
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPIRKitServiceId ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // 続いて検索条件を指定します。
    // NSPredicateを用いて、検索条件の表現（述語）を作成します。
    
    NSPredicate *pred = nil;
    if (serviceId) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@", DPIRKitServiceId, serviceId];
    }
    [fetchRequest setPredicate:pred];
    
    
    // NSFetchedResultsControllerを作成します。
    // 上記までで作成したFetchRequestを指定します。
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    // データ検索を行います。
    // 失敗した場合には、メソッドはfalseを返し、引数errorに値を詰めてくれます。
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    
    
    // 検索結果をコンソールに出力してみます。
    // fetchedObjectsというメソッドで、検索結果一覧を配列で受け取れます。
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    NSMutableArray *devices = [NSMutableArray new];
    for (int i = 0; i < moArray.count; i++) {
        DPIRKitVirtualDevice* device = [DPIRKitVirtualDevice new];
        NSManagedObject *object = [moArray objectAtIndex:i];
        device.serviceId= [object valueForKey:DPIRKitServiceId];
        device.deviceName = [object valueForKey:DPIRKitDeviceName];
        device.categoryName = [object valueForKey:DPIRKitCategoryName];
        [devices addObject:device];
    }
    return devices;
}


- (NSArray *)queryRESTfulRequestByServiceId:(NSString *)serviceId
                                    profile:(NSString *)profile {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定します。
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPIRKitIRURIMatchingDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 一度に読み込むサイズを指定します。
    [fetchRequest setFetchBatchSize:20];
    
    // 検索結果を保持する順序を指定します。
    // ここでは、keyというカラムの値の昇順で保持するように指定しています。
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPIRKitServiceId ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // 続いて検索条件を指定します。
    // NSPredicateを用いて、検索条件の表現（述語）を作成します。
    
    NSPredicate *pred = nil;
    if (serviceId && profile) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@ AND %K beginswith[c] %@",
                                        DPIRKitServiceId, serviceId, DPIRKitURI, profile];
    } else if (serviceId && !profile) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@", DPIRKitServiceId, serviceId];
    }
    [fetchRequest setPredicate:pred];
    
    
    // NSFetchedResultsControllerを作成します。
    // 上記までで作成したFetchRequestを指定します。
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    // データ検索を行います。
    // 失敗した場合には、メソッドはfalseを返し、引数errorに値を詰めてくれます。
    NSError *error = nil;
    NSMutableArray *requests = [NSMutableArray new];
    if (![fetchedResultsController performFetch:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return requests;
    }
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    for (int i = 0; i < moArray.count; i++) {
        DPIRKitRESTfulRequest* request = [DPIRKitRESTfulRequest new];
        NSManagedObject *object = [moArray objectAtIndex:i];
        request.serviceId= [object valueForKey:DPIRKitServiceId];
        request.ir = [object valueForKey:DPIRKitIR];
        request.uri = [object valueForKey:DPIRKitURI];
        request.method = [object valueForKey:DPIRKitMethod];
        request.name = [object valueForKey:DPIRKitName];
        [requests addObject:request];
        DPIRLog(@"ir:%@", request.ir);
    }
    DPIRLog(@"query success");
    return requests;
}

#pragma mark - Update


- (BOOL)updateRESTfulRequest:(DPIRKitRESTfulRequest *)request {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定します。
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPIRKitIRURIMatchingDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 一度に読み込むサイズを指定します。
    [fetchRequest setFetchBatchSize:20];
    
    // 検索結果を保持する順序を指定します。
    // ここでは、keyというカラムの値の昇順で保持するように指定しています。
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPIRKitServiceId ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // 続いて検索条件を指定します。
    // NSPredicateを用いて、検索条件の表現（述語）を作成します。
    
    NSPredicate *pred = nil;
    if (request) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND %K == %@",
                        DPIRKitServiceId, request.serviceId, DPIRKitMethod, request.method,
                        DPIRKitURI, request.uri];
    } else {
        return NO;
    }
    [fetchRequest setPredicate:pred];
    
    
    // NSFetchedResultsControllerを作成します。
    // 上記までで作成したFetchRequestを指定します。
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    // データ検索を行います。
    // 失敗した場合には、メソッドはfalseを返し、引数errorに値を詰めてくれます。
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    if (moArray.count <= 0) {
        return NO;
    }
    NSManagedObject *upObject = [moArray objectAtIndex:0];
    [upObject setValue:request.serviceId   forKey:DPIRKitServiceId];
    [upObject setValue:request.ir   forKey:DPIRKitIR];
    [upObject setValue:request.uri   forKey:DPIRKitURI];
    [upObject setValue:request.method   forKey:DPIRKitMethod];
    [upObject setValue:request.name forKey:DPIRKitName];
    if (![_managedObjectContext save:&error]) {
        DPIRLog(@"error = %@", error);
        return NO;
    }
    DPIRLog(@"Insert Completed.");
    return YES;
}

#pragma mark - Delete

- (BOOL)deleteVirtualDevice:(NSString *)serviceId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定します。
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPIRKitVirtualDeviceDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 一度に読み込むサイズを指定します。
    [fetchRequest setFetchBatchSize:20];
    
    // 検索結果を保持する順序を指定します。
    // ここでは、keyというカラムの値の昇順で保持するように指定しています。
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPIRKitServiceId ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // 続いて検索条件を指定します。
    // NSPredicateを用いて、検索条件の表現（述語）を作成します。
    
    NSPredicate *pred = nil;
    if (serviceId) {
        pred = [NSPredicate predicateWithFormat:@"%K == %@", DPIRKitServiceId, serviceId];
    } else {
        return NO;
    }
    [fetchRequest setPredicate:pred];
    
    
    // NSFetchedResultsControllerを作成します。
    // 上記までで作成したFetchRequestを指定します。
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    // データ検索を行います。
    // 失敗した場合には、メソッドはfalseを返し、引数errorに値を詰めてくれます。
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
    
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    if (moArray.count <= 0) {
        return NO;
    }
    NSManagedObject *object = [moArray objectAtIndex:0];
    [_managedObjectContext deleteObject:object];
    if (![_managedObjectContext save:&error]) {
        DPIRLog(@"error = %@", error);
        return NO;
    }
    DPIRLog(@"Delete Completed.");
    return YES;
}

- (BOOL)deleteRESTfulRequestForServiceId:(NSString *)serviceId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定します。
    NSEntityDescription *entity
    = [NSEntityDescription entityForName:DPIRKitIRURIMatchingDB inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 一度に読み込むサイズを指定します。
    [fetchRequest setFetchBatchSize:20];
    
    // 検索結果を保持する順序を指定します。
    // ここでは、keyというカラムの値の昇順で保持するように指定しています。
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:DPIRKitServiceId ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // 続いて検索条件を指定します。
    // NSPredicateを用いて、検索条件の表現（述語）を作成します。
    
    NSPredicate *pred = nil;
    if (serviceId) {
        pred = [NSPredicate predicateWithFormat:@"%@ == %@",
                DPIRKitServiceId, serviceId];
    } else {
        return NO;
    }
    [fetchRequest setPredicate:pred];
    
    
    // NSFetchedResultsControllerを作成します。
    // 上記までで作成したFetchRequestを指定します。
    NSFetchedResultsController *fetchedResultsController
    = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:_managedObjectContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    // データ検索を行います。
    // 失敗した場合には、メソッドはfalseを返し、引数errorに値を詰めてくれます。
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DPIRLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
    
    NSArray *moArray = [fetchedResultsController fetchedObjects];
    if (moArray.count <= 0) {
        return NO;
    }
    NSManagedObject *object = [moArray objectAtIndex:0];
    [_managedObjectContext deleteObject:object];
    if (![_managedObjectContext save:&error]) {
        DPIRLog(@"error = %@", error);
        return NO;
    }
    DPIRLog(@"Delete Completed.");
    return YES;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
