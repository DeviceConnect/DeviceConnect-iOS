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

@end


@implementation DPAllJoynHandler


- (instancetype) init {
    self = [super init];
    if (self) {
        _handlerQueue =
        dispatch_queue_create("org.deviceconnect.deviceplugin.handlerQueue",
                              DISPATCH_QUEUE_SERIAL);
        _discoveredServices = [DPAllJoynSynchronizedMutableDictionary new];
    }
    return self;
}


- (void)initAllJoynContextWithBlock:(void(^)(BOOL result))block
{
    NSLog(@"%s: init", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
                NSLog(@"Bus start failed.");
                block(NO);
                return;
            }
            
            // Connect to the message bus.
            //
            status = [self.bus connectWithArguments:@"null:"];
            
            if (ER_OK != status) {
                NSLog(@"Bus connect failed.");
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
    NSLog(@"%s: destroy", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
    NSLog(@"%s: discover", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
    NSLog(@"%s: joinSession", __PRETTY_FUNCTION__);
    if (!busName) {
        NSLog(@"%s: busName can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
    NSLog(@"%s: leaveSession: %u", __PRETTY_FUNCTION__, sessionId);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
        NSLog(@"block can not be nil.");
        return;
    }
    if (!service) {
        NSLog(@"service can not be nil.");
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
    NSLog(@"%s: Ping the service with bus name \"%@\"",
          class_getName([self class]), busName);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
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
            NSLog(@"Failed to introspect a remote bus object.");
            return nil;
        }
        return proxy;
    } else {
        return nil;
    }
}


- (void)pingTimerMethod:(NSTimer *)timer
{
    NSLog(@"%s: Sending pings to discovered services...",
          class_getName([self class]));
    
    for (DPAllJoynServiceEntity *serviceEntity in
         [_discoveredServices cloneDictionary].allValues) {
        [self pingWithBusName:serviceEntity.busName
                        block:^(BOOL result)
         {
             if (result) {
                 NSLog(@"Ping succeeded: %@", serviceEntity.serviceName);
                 serviceEntity.lastAlive = [NSDate date];
             }
             else {
                 if (serviceEntity.lastAlive.timeIntervalSinceNow
                     > DPAllJoynAliveTimeout) {
                     NSLog(@"Ping failed: %@."
                           " Removing it from discovered services...",
                           serviceEntity.serviceName);
                     [_discoveredServices removeObjectForKey:serviceEntity.appId];
                 }
             }
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


// =============================================================================
#pragma mark - AJNAboutListener


- (void)didReceiveAnnounceOnBus:(NSString *)busName
                    withVersion:(uint16_t)version
                withSessionPort:(AJNSessionPort)port
          withObjectDescription:(AJNMessageArgument *)objectDescriptionArg
               withAboutDataArg:(AJNMessageArgument *)aboutDataArg
{
    NSLog(@"%s: busName:%@ version:%u port:%u\nobjectDescriptionArg:%@\naboutDataArg:%@",
          __PRETTY_FUNCTION__,
          busName, version, port, objectDescriptionArg, aboutDataArg);
    
    DPAllJoynServiceEntity *service =
    [[DPAllJoynServiceEntity alloc] initWithBusName:busName
                                               port:port
                                          aboutData:aboutDataArg
                              busObjectDescriptions:objectDescriptionArg];
    
    NSLog(@"%s: Service found: %@", class_getName([self class]), service.serviceName);
    
    if (![DPAllJoynSupportCheck isSupported:objectDescriptionArg]) {
        NSLog(@"Required I/Fs are missing. Ignoring \"%@\" ...",
              service.serviceName);
        return;
    }
    
    [_discoveredServices setObject:service forKey:service.appId];
    
    // TENTATIVE
    [self performOneShotSessionWithBusName:service
                                     block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             NSLog(@"Failed to join a session.");
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [self proxyObjectWithService:service
                     proxyObjectClass:LSFLampObjectProxy.class
                            interface:@"org.allseen.LSF.LampState"
                            sessionID:sessionId.unsignedIntValue];
         QStatus status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSLog(@"Failed to introspect a remote bus object.");
             return;
         }
         
     }];
}


// =============================================================================
#pragma mark - AJNBusListener


- (void)listenerDidRegisterWithBus:(AJNBusAttachment*)busAttachment
{
    NSLog(@"%s: busAttachment:%@", __PRETTY_FUNCTION__, busAttachment);
}


- (void)listenerDidUnregisterWithBus:(AJNBusAttachment*)busAttachment
{
    NSLog(@"%s: busAttachment:%@", __PRETTY_FUNCTION__, busAttachment);
}


- (void)didFindAdvertisedName:(NSString*)name
            withTransportMask:(AJNTransportMask)transport
                   namePrefix:(NSString*)namePrefix
{
    NSLog(@"%s: name:%@ transport:%u namePrefix:%@", __PRETTY_FUNCTION__,
          name, transport, namePrefix);
}


- (void)didLoseAdvertisedName:(NSString*)name
            withTransportMask:(AJNTransportMask)transport
                   namePrefix:(NSString*)namePrefix
{
    NSLog(@"%s: name:%@ transport:%u namePrefix:%@", __PRETTY_FUNCTION__,
          name, transport, namePrefix);
}


- (void)nameOwnerChanged:(NSString*)name
                      to:(NSString*)newOwner
                    from:(NSString*)previousOwner
{
    NSLog(@"%s: name:%@ newOwner:%@ previousOwner:%@", __PRETTY_FUNCTION__,
          name, newOwner, previousOwner);
}


- (void)busWillStop
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)busDidDisconnect
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


// =============================================================================
#pragma mark - AJNSessionListener methods


- (void)sessionWasLost:(AJNSessionId)sessionId
             forReason:(AJNSessionLostReason)reason
{
    NSLog(@"%s: sessionId:%u forReason:%u", __PRETTY_FUNCTION__,
          sessionId, reason);
}


- (void)didAddMemberNamed:(NSString*)memberName
                toSession:(AJNSessionId)sessionId
{
    NSLog(@"%s: memberName:%@ sessionId:%u", __PRETTY_FUNCTION__,
          memberName, sessionId);
}


- (void)didRemoveMemberNamed:(NSString*)memberName
                 fromSession:(AJNSessionId)sessionId
{
    NSLog(@"%s: memberName:%@ fromSession:%u", __PRETTY_FUNCTION__,
          memberName, sessionId);
}

@end
