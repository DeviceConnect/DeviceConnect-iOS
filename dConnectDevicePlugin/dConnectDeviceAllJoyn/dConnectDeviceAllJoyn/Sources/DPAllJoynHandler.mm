//
//  DPAllJoynHandler.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynHandler.h"

#import <AllJoynFramework_iOS.h>
#import "AJNLSFControllerService.h"
#import "AJNLSFLamp.h"
#import "DPAllJoynConst.h"
#import "DPAllJoynServiceEntity.h"
#import "DPAllJoynSupportCheck.h"
#import "DPAllJoynSynchronizedMutableDictionary.h"
#import "DPAllJoynService.h"
#import "DPAlljoynReachability.h"

static int const DPAllJoynAliveTimeout = 30000;
static int const DPAllJoynPingTimeout = 5000;
static int const DPAllJoynPingInterval = 10;
static int const DPAllJoynDiscoverInterval = 30;
static size_t const DPAllJoynJoinRetryMax = 5;


@protocol AboutClientDelegate <NSObject>

- (void)didReceiveStatusUpdateMessage:(NSString *)message;

@end


@interface DPAllJoynHandler ()
<AJNBusListener, AJNSessionListener, AJNAboutListener>
{
@private
    dispatch_queue_t _handlerQueue;
    DPAllJoynSynchronizedMutableDictionary *_discoveredServices;
    NSTimer *_pingTimer;
    NSTimer *_discoverTimer;
}

@property (nonatomic, strong) AJNBusAttachment *bus;
@property (nonatomic) AJNSessionId sessionId;
@property (nonatomic, strong) NSString *foundServiceName;
//@property (nonatomic, strong) BasicObjectProxy *basicObjectProxy;
@property (nonatomic, strong) AJNAboutProxy *aboutProxy;
@property BOOL wasNameAlreadyFound;
@property (nonatomic, strong) DPAlljoynReachability *reachability;

@end


@implementation DPAllJoynHandler


- (instancetype) init {
    self = [super init];
    if (self) {
        _handlerQueue =
        dispatch_queue_create("org.deviceconnect.deviceplugin.handlerQueue",
                              DISPATCH_QUEUE_SERIAL);
        _discoveredServices = [DPAllJoynSynchronizedMutableDictionary new];
        
        // Reachabilityの初期処理
        self.reachability = [DPAlljoynReachability reachabilityWithHostName: @"www.google.com"];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(notifiedNetworkStatus:)
         name:DPAlljoynReachabilityChangedNotification
         object:nil];
        [self.reachability startNotifier];
    }
    return self;
}


- (void)initAllJoynContextWithBlock:(void(^)(BOOL result))block
{
    DCLogInfo(@"init");
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        if (!self.bus) {
            QStatus status;
            
            // Create a message bus.
            //
            self.bus =
            [[AJNBusAttachment alloc]
             initWithApplicationName:@"org.deviceconnect.deviceplugin.alljoyn"
             allowRemoteMessages:YES];
            
            [self.bus registerAboutListener:self];
            // Register a bus listener in order to receive discovery notifications.
            //
            [self.bus registerBusListener:self];
            
            // Start the message bus.
            //
            status = [self.bus start];
            
            if (ER_OK != status) {
                DCLogError(@"Bus start failed.");
                block(NO);
                return;
            }
            
            // Connect to the message bus.
            //
            status = [self.bus connectWithArguments:@"null:"];
            
            if (ER_OK != status) {
                DCLogError(@"Bus connect failed.");
                block(NO);
                return;
            }
            
            _pingTimer =
            [NSTimer timerWithTimeInterval:DPAllJoynPingInterval
                                    target:self
                                  selector:@selector(pingTimerMethod:)
                                  userInfo:nil
                                   repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_pingTimer
                                      forMode:NSDefaultRunLoopMode];
            
            _discoverTimer =
            [NSTimer timerWithTimeInterval:DPAllJoynDiscoverInterval
                                    target:self
                                  selector:@selector(discoverTimerMethod:)
                                  userInfo:nil
                                   repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_discoverTimer
                                      forMode:NSDefaultRunLoopMode];
            [_discoverTimer fire];
        }
        
        block(YES);
    });
}

- (void)destroyAllJoynContextWithBlock:(void(^)(BOOL result))block
{
    DCLogInfo(@"destroy");
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        if (_pingTimer) {
            [_pingTimer invalidate];
            _pingTimer = nil;
        }
        if (_discoverTimer) {
            [_discoverTimer invalidate];
            _discoverTimer = nil;
        }
        
        if (_bus) {
            [_bus disconnectWithArguments:@"null"];
            [_bus stop];
            _bus = nil;
        }
        block(YES);
    });
}


- (void)discoverServices:(void(^)(BOOL result))block
{
    DCLogInfo(@"discover");
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        // NOTE: the effect of whoImplementsInterface: for specific interfaces
        // can stack up, and unless all stacked-up effects are canceled, service
        // discovery for the specific interfaces can not be re-performed.
        // So the number of calls for whoImplementsInterface and
        // cancelWhoImplements must be balanced.
        static BOOL firstTime = YES;
        if (!firstTime) {
            for (NSArray *ifaceSet in DPAllJoynSupportedInterfaceSets) {
                for (NSString *iface in ifaceSet) {
                    [_bus cancelWhoImplements:iface];
                }
            }
            //            [_bus cancelWhoImplements:@"*"];
        } else {
            firstTime = NO;
        }
        
        // To realize fine-grained API availability for DeviceConnect,
        // query each AllJoyn interface separately.
        for (NSArray *ifaceSet : DPAllJoynSupportedInterfaceSets) {
            for (NSString *iface : ifaceSet) {
                [_bus whoImplementsInterface:iface];
            }
        }
        //        [self.bus whoImplementsInterface:@"*"];
    });
}


- (void)joinSessionWithBusName:(NSString *)busName
                          port:(AJNSessionPort)port
                         block:(void(^)(NSNumber *sessionId))block
{
    DCLogInfo(@"joinSession");
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    if (!busName) {
        DCLogError(@"%s: busName can not be nil.", __PRETTY_FUNCTION__);
        block(nil);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        AJNSessionOptions *sessionOptions =
        [[AJNSessionOptions alloc] initWithTrafficType:kAJNTrafficMessages
                                    supportsMultipoint:NO
                                             proximity:kAJNProximityAny
                                         transportMask:kAJNTransportMaskAny];
        AJNSessionId sessionId = [self.bus joinSessionWithName:busName
                                                        onPort:port
                                                  withDelegate:self
                                                       options:sessionOptions];
        
        if(sessionId != 0 && sessionId != -1) {
            block(@(sessionId));
        } else {
            block(nil);
        }
    });
}


- (void)leaveSessionWithSessionId:(AJNSessionId)sessionId
                            block:(void(^)(BOOL result))block
{
    DCLogInfo(@"leaveSession: %u", sessionId);
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        QStatus status = [self.bus leaveSession:sessionId];
        block(ER_OK == status);
    });
}


- (void)performOneShotSessionWithBusName:(DPAllJoynServiceEntity *)service
                                   block:(void(^)(DPAllJoynServiceEntity *service,
                                                  NSNumber *sessionId))block
{
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    if (!service) {
        DCLogError(@"%s: service can not be nil.", __PRETTY_FUNCTION__);
        block(nil, nil);
        return;
    }
    
    __block size_t failedCount = 0;
    id resultBlock;
    resultBlock = ^(NSNumber *sessionId)
    {
        if (sessionId) {
            block(service, sessionId);
            [self leaveSessionWithSessionId:sessionId.unsignedIntValue
                                      block:^(BOOL result) {}];
        } else if (failedCount <= DPAllJoynJoinRetryMax) {
            ++failedCount;
            [self joinSessionWithBusName:service.busName
                                    port:service.port
                                   block:resultBlock];
        } else {
            block(service, nil);
        }
    };
    [self joinSessionWithBusName:service.busName
                            port:service.port
                           block:resultBlock];
}


- (void)pingWithBusName:(NSString *)busName
                  block:(void(^)(BOOL result)) block
{
    DCLogInfo(@"Ping the service with bus name \"%@\"", busName);
    if (!block) {
        DCLogError(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        [self.bus pingPeerAsync:busName withTimeout:DPAllJoynPingTimeout completionBlock:
         ^(QStatus status, void *context) {
             block(ER_OK == status);
         } context:nil];
    });
}

- (AJNProxyBusObject *)proxyObjectWithService:(DPAllJoynServiceEntity *)service
                             proxyObjectClass:(Class)proxyObjectClass
                                    interface:(NSString *)interface
                                    sessionID:(AJNSessionId)sessionID
{
    NSDictionary *objPathDesc =
    [DPAllJoynSupportCheck objectPathDescriptionsWithInterface:@[interface]
                                                       service:service];
    
    if (objPathDesc.count != 0) {
        // TODO: Handling of multiple object paths with the same interfaces.
        // For the time being, use the first object path. Should these object
        // paths be arranged as separate Device Connect services that can be
        // accessed independently?
        AJNProxyBusObject *proxy =
        [[proxyObjectClass alloc]
         initWithBusAttachment:self.bus serviceName:service.busName
         objectPath:objPathDesc.allKeys[0] sessionId:sessionID];
        QStatus status = [proxy introspectRemoteObject];
        if (ER_OK != status) {
            DCLogError(@"Failed to introspect a remote bus object.");
            return nil;
        }
        return proxy;
    } else {
        return nil;
    }
}


- (void)pingTimerMethod:(NSTimer *)timer
{
    DCLogInfo(@"Sending pings to discovered services...");
    
    for (DPAllJoynServiceEntity *serviceEntity in
         [_discoveredServices cloneDictionary].allValues) {
        [self pingWithBusName:serviceEntity.busName
                        block:^(BOOL result)
         {
             if (result) {
                 DCLogInfo(@"Ping succeeded: %@", serviceEntity.serviceName);
                 serviceEntity.lastAlive = [NSDate date];
             }
             else {
                 if (-serviceEntity.lastAlive.timeIntervalSinceNow * 1000
                     > DPAllJoynAliveTimeout) {
                     DCLogInfo(@"Ping failed: %@."
                               " Removing it from discovered services...",
                               serviceEntity.serviceName);
                     [_discoveredServices removeObjectForKey:serviceEntity.appId];
                 }
             }
             
             // デバイス管理情報更新
             [self updateManageServices: YES];
         }];
    }
}


- (void)discoverTimerMethod:(NSTimer *)timer
{
    [self discoverServices:^(BOOL result) {
    }];
}


- (NSDictionary *)discoveredAllJoynServices
{
    return [_discoveredServices cloneDictionary];
}


- (void)postBlock:(void(^)())block withDelay:(int64_t)delayMillis
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(delayMillis * NSEC_PER_MSEC)),
                   dispatch_get_main_queue(), block);
}

// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    NetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self updateManageServices: NO];
    } else {
        [self updateManageServices: YES];
    }
}

// デバイス管理情報更新
- (void) updateManageServices: (BOOL) onlineForSet {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!_serviceProvider) {
            return;
        }

        // オフラインにする場合は、全サービスをオフラインにする(Wifi Offにされたことを想定)
        if (!onlineForSet) {
            for (DConnectService *service in [_serviceProvider services]) {
                [service setOnline: NO];
            }
            return;
        }

        // ServiceProviderに存在するサービスが検出されなかったならオフラインにする
        for (DConnectService *service in [_serviceProvider services]) {
            NSString *serviceId = [service serviceId];
            if (!self.discoveredAllJoynServices[serviceId]) {
                [service setOnline: NO];
            }
        }
        
        // サービス未登録なら登録する、登録済みならオンラインにする
        for (DPAllJoynServiceEntity *serviceEntity in [self.discoveredAllJoynServices allValues]) {
            DConnectService *service = [_serviceProvider service: serviceEntity.appId];
            if (service) {
                [service setName:serviceEntity.serviceName];
                [service setOnline: YES];
            } else {
                service = [[DPAllJoynService alloc] initWithServiceId:serviceEntity.appId
                                                          serviceName:serviceEntity.serviceName
                                                               plugin: self.plugin
                                                              handler:self];
                [_serviceProvider addService: service];
                [service setOnline:YES];
            }
        }
    }
}



// =============================================================================
#pragma mark - AJNAboutListener


- (void)didReceiveAnnounceOnBus:(NSString *)busName
                    withVersion:(uint16_t)version
                withSessionPort:(AJNSessionPort)port
          withObjectDescription:(AJNMessageArgument *)objectDescriptionArg
               withAboutDataArg:(AJNMessageArgument *)aboutDataArg
{
    DCLogInfo(@"busName:%@ version:%u port:%u\nobjectDescriptionArg:%@\naboutDataArg:%@",
              busName, version, port, objectDescriptionArg, aboutDataArg);
    
    DPAllJoynServiceEntity *service =
    [[DPAllJoynServiceEntity alloc] initWithBusName:busName
                                               port:port
                                          aboutData:aboutDataArg
                              busObjectDescriptions:objectDescriptionArg];
    
    DCLogInfo(@"Service found: %@", service.serviceName);
    
    if (![DPAllJoynSupportCheck isSupported:objectDescriptionArg]) {
        DCLogInfo(@"Required I/Fs are missing. Ignoring \"%@\" ...",
                  service.serviceName);
        return;
    }
    
    DPAllJoynServiceEntity *oldService =
    [_discoveredServices objectForKey:service.appId];
    if (oldService) {
        service.lastAlive = oldService.lastAlive;
    }
    [_discoveredServices setObject:service forKey:service.appId];
    
    // デバイス管理情報更新
    [self updateManageServices: YES];
}


// =============================================================================
#pragma mark - AJNBusListener


- (void)listenerDidRegisterWithBus:(AJNBusAttachment*)busAttachment
{
    DCLogInfo(@"busAttachment:%@", busAttachment);
}


- (void)listenerDidUnregisterWithBus:(AJNBusAttachment*)busAttachment
{
    DCLogInfo(@"busAttachment:%@", busAttachment);
}


- (void)didFindAdvertisedName:(NSString*)name
            withTransportMask:(AJNTransportMask)transport
                   namePrefix:(NSString*)namePrefix
{
    DCLogInfo(@"name:%@ transport:%u namePrefix:%@",
              name, transport, namePrefix);
}


- (void)didLoseAdvertisedName:(NSString*)name
            withTransportMask:(AJNTransportMask)transport
                   namePrefix:(NSString*)namePrefix
{
    DCLogInfo(@"name:%@ transport:%u namePrefix:%@",
              name, transport, namePrefix);
}


- (void)nameOwnerChanged:(NSString*)name
                      to:(NSString*)newOwner
                    from:(NSString*)previousOwner
{
    DCLogInfo(@"name:%@ newOwner:%@ previousOwner:%@",
              name, newOwner, previousOwner);
}


- (void)busWillStop
{
    DCLogInfo();
}


- (void)busDidDisconnect
{
    DCLogInfo();
}


// =============================================================================
#pragma mark - AJNSessionListener methods


- (void)sessionWasLost:(AJNSessionId)sessionId
             forReason:(AJNSessionLostReason)reason
{
    DCLogInfo(@"sessionId:%u forReason:%u", sessionId, reason);
}


- (void)didAddMemberNamed:(NSString*)memberName
                toSession:(AJNSessionId)sessionId
{
    DCLogInfo(@"memberName:%@ sessionId:%u", memberName, sessionId);
}


- (void)didRemoveMemberNamed:(NSString*)memberName
                 fromSession:(AJNSessionId)sessionId
{
    DCLogInfo(@"memberName:%@ fromSession:%u", memberName, sessionId);
}

@end
