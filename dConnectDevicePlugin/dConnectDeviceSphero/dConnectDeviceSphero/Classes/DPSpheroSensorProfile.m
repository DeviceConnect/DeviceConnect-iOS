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


typedef void (^QuaternionBlock)(DConnectMessage *);
typedef void (^LocatorBlock)(DConnectMessage *);
typedef void (^CollisionBlock)(DConnectMessage *);


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

        self.quaternionBlock = ^(DConnectMessage *msg) {
            [weakSelf sendMessage:msg
                        interface:DPSpheroProfileInterfaceQuaternion
                        attribute:DPSpheroProfileAttrOnQuaternion
                            param:DPSpheroProfileParamQuaternion];
        };
        
        self.locatorBlock = ^(DConnectMessage *msg) {
            [weakSelf sendMessage:msg
                        interface:DPSpheroProfileInterfaceLocator
                        attribute:DPSpheroProfileAttrOnLocator
                            param:DPSpheroProfileParamLocator];
        };
        
        self.collisionBlock = ^(DConnectMessage *msg) {
            [weakSelf sendMessage:msg
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
                         
                         weakSelf.quaternionOnceBlock = ^(DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamQuaternion];
                             
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                             weakSelf.quaternionOnceBlock = nil;
                             
                             if (![weakSelf hasQuaternionEventList]) {
                                 [[DPSpheroManager sharedManager] stopSensorQuaternion];
                             }
                         };
                         
                         if (![weakSelf hasQuaternionEventList]) {
                             [[DPSpheroManager sharedManager] startSensorQuaternion];
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
                         
                         weakSelf.locatorOnceBlock = ^(DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamLocator];
                             
                             weakSelf.locatorOnceBlock = nil;
                             
                             if (![weakSelf hasLocatorEventList]) {
                                 [[DPSpheroManager sharedManager] stopSensorLocator];
                             }
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                         };
                         
                         if (![weakSelf hasLocatorEventList]) {
                             [[DPSpheroManager sharedManager] startSensorLocator];
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
                         
                         weakSelf.collisionOnceBlock = ^(DConnectMessage *msg) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [response setMessage:msg forKey:DPSpheroProfileParamCollision];
                             
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                             weakSelf.collisionOnceBlock = nil;
                             
                             if (![weakSelf hasCollisionEventList]) {
                                 [[DPSpheroManager sharedManager] stopSensorCollision];
                             }
                         };
                         
                         if (![weakSelf hasCollisionEventList]) {
                             [[DPSpheroManager sharedManager] startSensorCollision];
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
                             [[DPSpheroManager sharedManager] startSensorQuaternion];
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
                             [[DPSpheroManager sharedManager] startSensorLocator];
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
                             [[DPSpheroManager sharedManager] startSensorCollision];
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
                                [[DPSpheroManager sharedManager] stopSensorQuaternion];
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
                                [[DPSpheroManager sharedManager] stopSensorLocator];
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
                                [[DPSpheroManager sharedManager] stopSensorCollision];
                            }];
                            return YES;
                        }];
    }
    return self;
}

// 共通メッセージ送信
- (void)sendMessage:(DConnectMessage*)message
          interface:(NSString *)interface
          attribute:(NSString *)attribute
              param:(NSString*)param
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                         profile:DPSpheroProfileName
                                       interface:interface
                                       attribute:attribute];
    if (events == 0 && interface) {
        if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceQuaternion] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorQuaternion];
        } else if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceLocator] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorLocator];
        } else if ([interface localizedCaseInsensitiveCompare:DPSpheroProfileInterfaceCollision] == NSOrderedSame) {
            [[DPSpheroManager sharedManager] stopSensorCollision];
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
             callback:(void(^)())callback
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

- (BOOL)hasQuaternionEventList
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceQuaternion
                                        attribute:DPSpheroProfileAttrOnQuaternion];
    return events && events.count > 0;
}

- (BOOL)hasLocatorEventList
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceLocator
                                        attribute:DPSpheroProfileAttrOnLocator];
    return events && events.count > 0;
}

- (BOOL)hasCollisionEventList
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                          profile:DPSpheroProfileName
                                        interface:DPSpheroProfileInterfaceCollision
                                        attribute:DPSpheroProfileAttrOnCollision];
    return events && events.count > 0;
}

#pragma mark - DPSpheroManagerSensorDelegate

// Quaternionのイベント処理
- (void)spheroManagerStreamingQuaternion:(DPQuaternion)quaternion
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
        block(msg);
    }

    if (self.quaternionOnceBlock) {
        QuaternionBlock block = self.quaternionOnceBlock;
        block(msg);
    }
}

// Locatorのイベント処理
- (void)spheroManagerStreamingLocatorPos:(CGPoint)pos
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
        block(msg);
    }
    
    if (self.locatorOnceBlock) {
        LocatorBlock block = self.locatorOnceBlock;
        block(msg);
    }
}

// Collisionのイベント処理
- (void)spheroManagerStreamingCollisionImpactAcceleration:(DPPoint3D)accel
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
    [msg setDouble:time forKey:DPSpheroProfileParamImpactTimestamp];
    
    if (self.collisionBlock) {
        CollisionBlock block = self.collisionBlock;
        block(msg);
    }
    
    if (self.collisionOnceBlock) {
        CollisionBlock block = self.collisionOnceBlock;
        block(msg);
    }
}

@end
