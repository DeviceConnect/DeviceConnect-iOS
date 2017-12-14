//
//  DPSpheroSensorProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPSpheroSensorProfile.h"
#import "DPSpheroDevicePlugin.h"
#import "DPSpheroManager.h"


typedef void (^QuaternionBlock)(NSString* serviceId, DConnectMessage *);
typedef void (^LocatorBlock)(NSString* serviceId, DConnectMessage *);
typedef void (^CollisionBlock)(NSString* serviceId, DConnectMessage *);


@interface DPSpheroSensorProfile() <DPSpheroManagerSensorDelegate>

@property id quaternionBlock;
@property id quaternionOnceBlock;

@property id locatorBlock;
@property id locatorOnceBlock;

@property id collisionBlock;
@property id collisionOnceBlock;

@end

@implementation DPSpheroSensorProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {

        self.quaternionOnceBlock = nil;
        self.locatorOnceBlock = nil;
        self.collisionOnceBlock = nil;
        [DPSpheroManager sharedManager].sensorDelegate = self;
        
        __weak DPSpheroSensorProfile *weakSelf = self;

        self.quaternionBlock = ^(NSString* serviceId, DConnectMessage *msg) {
            [weakSelf sendMessageForServiceId:(NSString*)serviceId
                                      message:msg
                        interface:DPSpheroProfileInterfaceQuaternion
                        attribute:DPSpheroProfileAttrOnQuaternion
                            param:DPSpheroProfileParamQuaternion];
        };
        
        self.locatorBlock = ^(NSString* serviceId, DConnectMessage *msg) {
            [weakSelf sendMessageForServiceId:(NSString*)serviceId
                                      message:msg
                        interface:DPSpheroProfileInterfaceLocator
                        attribute:DPSpheroProfileAttrOnLocator
                            param:DPSpheroProfileParamLocator];
        };
        
        self.collisionBlock = ^(NSString* serviceId, DConnectMessage *msg) {
            [weakSelf sendMessageForServiceId:(NSString*)serviceId
                                      message:msg
                        interface:DPSpheroProfileInterfaceCollision
                        attribute:DPSpheroProfileAttrOnCollision
                            param:DPSpheroProfileParamCollision];
        };
        
        // API登録(didReceiveGetOnQuaternionRequest相当)
        NSString *getOnQuaternionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceQuaternion
                                                  attributeName: DPSpheroProfileAttrOnQuaternion];
        [self addGetPath: getOnQuaternionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         weakSelf.quaternionOnceBlock = ^(NSString* serviceId, DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamQuaternion];
                             
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                             weakSelf.quaternionOnceBlock = nil;
                             
                             if (![weakSelf hasQuaternionEventListForServiceId:serviceId]) {
                                 [[DPSpheroManager sharedManager] stopSensorQuaternionForServiceId:serviceId];
                             }
                         };
                         
                         if (![weakSelf hasQuaternionEventListForServiceId:serviceId]) {
                             [[DPSpheroManager sharedManager] startSensorQuaternionForServiceId:serviceId];
                         }
                         
                         return NO;
                     }];
        
        // API登録(didReceiveGetOnLocatorRequest相当)
        NSString *getOnLocatorRequestApiPath = [self apiPath: DPSpheroProfileInterfaceLocator
                                               attributeName: DPSpheroProfileAttrOnLocator];
        [self addGetPath: getOnLocatorRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         weakSelf.locatorOnceBlock = ^(NSString* serviceId, DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamLocator];
                             
                             weakSelf.locatorOnceBlock = nil;
                             
                             if (![weakSelf hasLocatorEventListForServiceId:serviceId]) {
                                 [[DPSpheroManager sharedManager] stopSensorLocatorForServiceId:serviceId];
                             }
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                         };
                         
                         if (![weakSelf hasLocatorEventListForServiceId:serviceId]) {
                             [[DPSpheroManager sharedManager] startSensorLocatorForServiceId:serviceId];
                         }
                         
                         return NO;
                     }];
        
        // API登録(didReceiveGetOnCollisionRequest相当)
        NSString *getOnCollisionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceCollision
                                                 attributeName: DPSpheroProfileAttrOnCollision];
        [self addGetPath: getOnCollisionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                        
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         weakSelf.collisionOnceBlock = ^(NSString* serviceId, DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamCollision];
                             
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                             weakSelf.collisionOnceBlock = nil;
                             
                             if (![weakSelf hasCollisionEventListForServiceId:serviceId]) {
                                 [[DPSpheroManager sharedManager] stopSensorCollisionForServiceId:serviceId];
                             }
                         };
                         
                         if (![weakSelf hasCollisionEventListForServiceId:serviceId]) {
                             [[DPSpheroManager sharedManager] startSensorCollisionForServiceId:serviceId];
                         }
                         
                         return NO;
                     }];

        // API登録(didReceivePutOnQuaternionRequest相当)
        NSString *putOnQuaternionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceQuaternion
                                                  attributeName: DPSpheroProfileAttrOnQuaternion];
        [self addPutPath: putOnQuaternionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                        
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         [weakSelf handleRequest:request response:response isRemove:NO callback:^{
                             [[DPSpheroManager sharedManager] startSensorQuaternionForServiceId:serviceId];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnLocatorRequest相当)
        NSString *putOnLocatorRequestApiPath = [self apiPath: DPSpheroProfileInterfaceLocator
                                               attributeName: DPSpheroProfileAttrOnLocator];
        [self addPutPath: putOnLocatorRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                        
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         [weakSelf handleRequest:request response:response isRemove:NO callback:^{
                             [[DPSpheroManager sharedManager] startSensorLocatorForServiceId:serviceId];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnCollisionRequest相当)
        NSString *putOnCollisionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceCollision
                                                 attributeName: DPSpheroProfileAttrOnCollision];
        [self addPutPath: putOnCollisionRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                        
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         [weakSelf handleRequest:request response:response isRemove:NO callback:^{
                             [[DPSpheroManager sharedManager] startSensorCollisionForServiceId:serviceId];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnQuaternionRequest相当)
        NSString *deleteOnQuaternionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceQuaternion
                                                     attributeName: DPSpheroProfileAttrOnQuaternion];
        [self addDeletePath: deleteOnQuaternionRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                            NSString *serviceId = [request serviceId];
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            [weakSelf handleRequest:request response:response isRemove:YES callback:^{
                                [[DPSpheroManager sharedManager] stopSensorQuaternionForServiceId:serviceId];
                            }];
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnLocatorRequest相当)
        NSString *deleteOnLocatorRequestApiPath = [self apiPath: DPSpheroProfileInterfaceLocator
                                                  attributeName: DPSpheroProfileAttrOnLocator];
        [self addDeletePath: deleteOnLocatorRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                            NSString *serviceId = [request serviceId];
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            [weakSelf handleRequest:request response:response isRemove:YES callback:^{
                                [[DPSpheroManager sharedManager] stopSensorLocatorForServiceId:serviceId];
                            }];
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnCollisionRequest相当)
        NSString *deleteOnCollisionRequestApiPath = [self apiPath: DPSpheroProfileInterfaceCollision
                                                    attributeName: DPSpheroProfileAttrOnCollision];
        [self addDeletePath: deleteOnCollisionRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                            NSString *serviceId = [request serviceId];
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            [weakSelf handleRequest:request response:response isRemove:YES callback:^{
                                [[DPSpheroManager sharedManager] stopSensorCollisionForServiceId:serviceId];
                            }];
                            return YES;
                        }];
    }
    return self;
}

// 共通メッセージ送信
- (void)sendMessageForServiceId:(NSString*)serviceId
                        message:(DConnectMessage*)message
          interface:(NSString *)interface
          attribute:(NSString *)attribute
              param:(NSString*)param
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:serviceId
                                         profile:DPSpheroProfileName
                                       interface:interface
                                       attribute:attribute];
    if (events == 0 && interface) {
        if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceQuaternion] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorQuaternionForServiceId:serviceId];
        } else if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceLocator] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorLocatorForServiceId:serviceId];
        } else if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceCollision] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorCollisionForServiceId:serviceId];
        }
    }
    for (DConnectEvent *event in events) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
        [eventMsg setMessage:message forKey:param];
        DConnectDevicePlugin *plugin = (DConnectDevicePlugin *)self.plugin;
        [plugin sendEvent:eventMsg];
    }
   
}

// 共通リクエスト処理
- (void)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             isRemove:(BOOL)isRemove
             callback:(void(^)(void))callback
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    DConnectEventError error;
    if (isRemove) {
        error = [mgr removeEventForRequest:request];
    } else {
        error = [mgr addEventForRequest:request];
    }
    if (error == DConnectEventErrorNone) {
        callback();
        [response setResult:DConnectMessageResultTypeOk];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
}

- (BOOL)hasQuaternionEventListForServiceId:(NSString*)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:serviceId
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceQuaternion
                                        attribute:DPSpheroProfileAttrOnQuaternion];
    return events && events.count > 0;
}

- (BOOL)hasLocatorEventListForServiceId:(NSString*)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:serviceId
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceLocator
                                        attribute:DPSpheroProfileAttrOnLocator];
    return events && events.count > 0;
}

- (BOOL)hasCollisionEventListForServiceId:(NSString*)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:serviceId
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceCollision
                                        attribute:DPSpheroProfileAttrOnCollision];
    return events && events.count > 0;
}

#pragma mark - DPSpheroManagerSensorDelegate

// Quaternionのイベント処理
- (void)spheroManagerStreamingQuaternionForServiceId:(NSString*)serviceId
                                          quaternion:(DPQuaternion)quaternion
                                            interval:(int)interval;
{
    DConnectMessage *msg = [DConnectMessage message];
    [msg setDouble:quaternion.q0 forKey:DPSpheroProfileParamQ0];
    [msg setDouble:quaternion.q1 forKey:DPSpheroProfileParamQ1];
    [msg setDouble:quaternion.q2 forKey:DPSpheroProfileParamQ2];
    [msg setDouble:quaternion.q3 forKey:DPSpheroProfileParamQ3];
    [msg setInteger:interval forKey:DPSpheroProfileParamInterval];
    
    if (self.quaternionBlock) {
        QuaternionBlock block = self.quaternionBlock;
        block(serviceId, msg);
    }

    if (self.quaternionOnceBlock) {
        QuaternionBlock block = self.quaternionOnceBlock;
        block(serviceId, msg);
    }
}

// Locatorのイベント処理
- (void)spheroManagerStreamingLocatorForServiceId:(NSString*)serviceId
                                              pos:(CGPoint)pos
                                         velocity:(CGPoint)velocity
                                         interval:(int)interval
{
    DConnectMessage *msg = [DConnectMessage message];
    [msg setDouble:pos.x forKey:DPSpheroProfileParamPositionX];
    [msg setDouble:pos.y forKey:DPSpheroProfileParamPositionY];
    [msg setDouble:velocity.x forKey:DPSpheroProfileParamVelocityX];
    [msg setDouble:velocity.y forKey:DPSpheroProfileParamVelocityY];
    [msg setInteger:interval forKey:DPSpheroProfileParamInterval];
    
    
    if (self.locatorBlock) {
        LocatorBlock block = self.locatorBlock;
        block(serviceId, msg);
    }
    
    if (self.locatorOnceBlock) {
        LocatorBlock block = self.locatorOnceBlock;
        block(serviceId, msg);
    }
}

// Collisionのイベント処理
- (void)spheroManagerStreamingCollisionForServiceId:(NSString*)serviceId
                                 impactAcceleration:(DPPoint3D)accel
                                               axis:(CGPoint)axis
                                              power:(CGPoint)power
                                              speed:(float)speed
                                               time:(NSTimeInterval)time
{
    DConnectMessage *msg = [DConnectMessage message];
    DConnectMessage *impactAcceleration = [DConnectMessage message];
    [impactAcceleration setDouble:accel.x forKey:DPSpheroProfileParamX];
    [impactAcceleration setDouble:accel.y forKey:DPSpheroProfileParamY];
    [impactAcceleration setDouble:accel.z forKey:DPSpheroProfileParamZ];
    [msg setMessage:impactAcceleration forKey:DPSpheroProfileParamImpactAcceleration];
    
    DConnectMessage *impactAxis = [DConnectMessage message];
    [impactAxis setBool:axis.x forKey:DPSpheroProfileParamX];
    [impactAxis setBool:axis.y forKey:DPSpheroProfileParamY];
    [msg setMessage:impactAxis forKey:DPSpheroProfileParamImpactAxis];
    
    DConnectMessage *impactPower = [DConnectMessage message];
    [impactPower setDouble:power.x forKey:DPSpheroProfileParamX];
    [impactPower setDouble:power.y forKey:DPSpheroProfileParamY];
    [msg setMessage:impactPower forKey:DPSpheroProfileParamImpactPower];
    [msg setDouble:speed forKey:DPSpheroProfileParamImpactSpeed];
    [msg setLong:(long) time forKey:DPSpheroProfileParamImpactTimeStamp];
    [msg setString:[DConnectRFC3339DateUtils stringWithTimeStamp :(long) time] forKey:DPSpheroProfileParamImpactTimeStampString];

    if (self.collisionBlock) {
        CollisionBlock block = self.collisionBlock;
        block(serviceId, msg);
    }
    
    if (self.collisionOnceBlock) {
        CollisionBlock block = self.collisionOnceBlock;
        block(serviceId, msg);
    }
}

@end
