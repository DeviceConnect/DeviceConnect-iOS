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
#import "DPSpheroServiceDiscoveryProfile.h"


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
        self.delegate = self;
        self.quaternionOnceBlock = nil;
        self.locatorOnceBlock = nil;
        self.collisionOnceBlock = nil;
        [DPSpheroManager sharedManager].sensorDelegate = self;
        
        __unsafe_unretained typeof(self) weakSelf = self;

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
    if (events == 0) {
        if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceQuaternion]) {
            [[DPSpheroManager sharedManager] stopSensorQuaternion];
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceLocator]) {
            [[DPSpheroManager sharedManager] stopSensorLocator];
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceCollision]) {
            [[DPSpheroManager sharedManager] stopSensorCollision];
        }
    }
    for (DConnectEvent *event in events) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
        [eventMsg setMessage:message forKey:param];
        DConnectDevicePlugin *plugin = (DConnectDevicePlugin *)self.provider;
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
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
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


#pragma mark - Quaternion

- (BOOL)                     profile:(DPSpheroProfile *)profile
    didReceiveGetOnQuaternionRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();

    __unsafe_unretained typeof(self) weakSelf = self;
    
    self.quaternionOnceBlock = ^(DConnectMessage *msg) {
        [response setResult:DConnectMessageResultTypeOk];
        [response setMessage:msg forKey:DPSpheroProfileParamQuaternion];

        [[DConnectManager sharedManager] sendResponse:response];
        
        weakSelf.quaternionOnceBlock = nil;

        if (![weakSelf hasQuaternionEventList]) {
            [[DPSpheroManager sharedManager] stopSensorQuaternion];
        }
    };
    
    if (![self hasQuaternionEventList]) {
        [[DPSpheroManager sharedManager] startSensorQuaternion];
    }
    
    return NO;
}


// Quaternionのイベントを登録
- (BOOL)                     profile:(DPSpheroProfile *)profile
    didReceivePutOnQuaternionRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:NO callback:^{
        [[DPSpheroManager sharedManager] startSensorQuaternion];
    }];
    return YES;
}

// Quaternionのイベント登録を解除
- (BOOL)                        profile:(DPSpheroProfile *)profile
    didReceiveDeleteOnQuaternionRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:YES callback:^{
        [[DPSpheroManager sharedManager] stopSensorQuaternion];
    }];
    return YES;
}


#pragma mark - Locator

// Locatorのイベントを登録
- (BOOL)                  profile:(DPSpheroProfile *)profile
    didReceiveGetOnLocatorRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    self.locatorOnceBlock = ^(DConnectMessage *msg) {
        [response setResult:DConnectMessageResultTypeOk];
        [response setMessage:msg forKey:DPSpheroProfileParamLocator];
        
        weakSelf.locatorOnceBlock = nil;
        
        if (![weakSelf hasLocatorEventList]) {
            [[DPSpheroManager sharedManager] stopSensorLocator];
        }
        [[DConnectManager sharedManager] sendResponse:response];

    };
    
    if (![self hasLocatorEventList]) {
        [[DPSpheroManager sharedManager] startSensorLocator];
    }
    
    return NO;
}


// Locatorのイベントを登録
- (BOOL)                  profile:(DPSpheroProfile *)profile
    didReceivePutOnLocatorRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
                       sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();

    [self handleRequest:request response:response isRemove:NO callback:^{
        [[DPSpheroManager sharedManager] startSensorLocator];
    }];
    return YES;
}

// Locatorのイベント登録を解除
- (BOOL)                     profile:(DPSpheroProfile *)profile
    didReceiveDeleteOnLocatorRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                          sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:YES callback:^{
        [[DPSpheroManager sharedManager] stopSensorLocator];
    }];
    return YES;
}


#pragma mark - Collision

- (BOOL)                    profile:(DPSpheroProfile *)profile
    didReceiveGetOnCollisionRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    self.collisionOnceBlock = ^(DConnectMessage *msg) {
        [response setResult:DConnectMessageResultTypeOk];
        [response setMessage:msg forKey:DPSpheroProfileParamCollision];
        
        [[DConnectManager sharedManager] sendResponse:response];
        
        weakSelf.collisionOnceBlock = nil;
        
        if (![weakSelf hasCollisionEventList]) {
            [[DPSpheroManager sharedManager] stopSensorCollision];
        }
    };
    
    if (![self hasCollisionEventList]) {
        [[DPSpheroManager sharedManager] startSensorCollision];
    }
    
    return NO;
}

// Collisionのイベントを登録
- (BOOL)                    profile:(DPSpheroProfile *)profile
    didReceivePutOnCollisionRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:NO callback:^{
        [[DPSpheroManager sharedManager] startSensorCollision];
    }];
    return YES;
}

// Collisionのイベント登録を解除
- (BOOL)                       profile:(DPSpheroProfile *)profile
    didReceiveDeleteOnCollisionRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                             serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:YES callback:^{
        [[DPSpheroManager sharedManager] stopSensorCollision];
    }];
    return YES;
}

@end
