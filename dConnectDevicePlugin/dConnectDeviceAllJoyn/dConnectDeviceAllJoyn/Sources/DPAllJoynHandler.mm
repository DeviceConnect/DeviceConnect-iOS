//
//  DPAllJoynHandler.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynHandler.h"

#import <AllJoynFramework_iOS.h>
#import "DPAllJoynSynchronizedMutableDictionary.h"
#import "DPAllJoynServiceEntity.h"


NSArray *const DPAllJoynSingleLampInterfaceSet =
  @[
    // AllJoyn Lighting service framework, Lamp service
    @"org.allseen.LSF.LampDetails"
    , @"org.allseen.LSF.LampParameters"
    , @"org.allseen.LSF.LampService"
    , @"org.allseen.LSF.LampState"
    ];
NSArray *const DPAllJoynLampControllerInterfaceSet =
  @[
    //                    // AllJoyn Lighting service framework, Controller Service
    @"org.allseen.LSF.ControllerService"
    , @"org.allseen.LSF.ControllerService.Lamp"
    //                    , @"org.allseen.LSF.ControllerService.LampGroup"
    //                    , @"org.allseen.LSF.ControllerService.Preset"
    //                    , @"org.allseen.LSF.ControllerService.Scene"
    //                    , @"org.allseen.LSF.ControllerService.MasterScene"
    //                    , @"org.allseen.LeaderElectionAndStateSync"
    ];
NSArray *const DPAllJoynSupportedInterfaceSets =
  @[
    DPAllJoynSingleLampInterfaceSet
    , DPAllJoynLampControllerInterfaceSet
    ];

static NSString *const VERSION = @"1.0.0";
static int const PING_TIMEOUT = 5000;
static int const PING_INTERVAL = 20;
static int const DISCOVER_INTERVAL = 30;


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
@property (nonatomic, strong) NSCondition *joinedSessionCondition;
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
            [NSTimer timerWithTimeInterval:PING_INTERVAL
                                    target:self
                                  selector:@selector(pingTimerMethod:)
                                  userInfo:nil
                                   repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_pingTimer
                                      forMode:NSDefaultRunLoopMode];
            
            _discoverTimer =
            [NSTimer timerWithTimeInterval:DISCOVER_INTERVAL
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
        [self.bus enableConcurrentCallbacks];
        AJNSessionId sessionId = [self.bus joinSessionWithName:busName onPort:port withDelegate:self options:sessionOptions];
        
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
    NSLog(@"%s: leaveSession", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        QStatus status = [self.bus leaveSession:sessionId];
        block(ER_OK == status);
    });
}


- (void)pingWithBunName:(NSString *)busName
                  block:(void(^)(BOOL result)) block
{
    NSLog(@"%s: Ping the service with bus name \"%@\"",
          class_getName([self class]), busName);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(_handlerQueue, ^{
        QStatus status = [self.bus pingPeer:busName withTimeout:5000];
        block(ER_OK == status);
    });
}


- (void)pingTimerMethod:(NSTimer *)timer
{
    NSLog(@"%s: Sending pings to discovered services...",
          class_getName([self class]));
    
    for (DPAllJoynServiceEntity *serviceEntity in
         [_discoveredServices cloneDictionary].allValues) {
        [self pingWithBunName:serviceEntity.busName
                        block:^(BOOL result)
         {
             if (!result) {
                 NSLog(@"No ping from the service with bus name \"%@\"."
                       " Removing it from discovered services...",
                       serviceEntity.serviceName);
                 [_discoveredServices removeObjectForKey:serviceEntity.busName];
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
                                 (int64_t)(delayMillis * NSEC_PER_MSEC)), dispatch_get_main_queue(), block);
}


+ (BOOL) isSupported:(AJNMessageArgument *)busObjectDescriptions
{
    NSMutableSet *interfaces = [NSMutableSet new];
    
    QStatus status;
    size_t size;
    MsgArg *entries;
    status = [busObjectDescriptions value:@"a(oas)", &size, &entries];
    if (ER_OK != status) {
        NSLog(@"Failed to parse bus object descriptions.");
        return NO;
    }
    for (size_t i = 0; i < size; ++i) {
        char *objPath;
        size_t size2;
        MsgArg *entries2;
        status = entries[i].Get("(oas)", &objPath, &size2, &entries2);
        if (ER_OK != status) {
            NSLog(@"Failed to parse a bus object description. Skipping it...");
            continue;
        }
        for (size_t j = 0; j < size2; ++j) {
            char *iface;
            status = entries2[j].Get("s", &iface);
            if (ER_OK != status) {
                NSLog(@"Failed to parse a supported interface in a bus object."
                      " Skipping it...");
                continue;
            }
            [interfaces addObject:@(iface)];
        }
    }
    
    // Each supported AllJoyn interface set represents a collection of required AllJoyn
    // interfaces to realize a certain DeviceConnect profile (e.g. AllJoyn Lamp service
    // interfaces are required for the DeviceConnect Light profile).
    // If AllJoyn bus object in question contains any of supported interface sets, then
    // assumedly this bus object is able to become a DeviceConect service.
    for (NSArray *supportedInterfaceSet : DPAllJoynSupportedInterfaceSets) {
        BOOL allSupported = YES;
        for (NSString *supportedInterface : supportedInterfaceSet) {
            if (![interfaces containsObject:supportedInterface]) {
                allSupported = NO;
                break;
            }
        }
        if (allSupported) {
            return YES;
        }
    }
    return NO;
}


// =========================================================
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
                                       proxyObjects:objectDescriptionArg];
    
    NSLog(@"%s: Service found: %@", class_getName([self class]), service.serviceName);
    
    if (![DPAllJoynHandler isSupported:objectDescriptionArg]) {
        NSLog(@"Required I/Fs are missing. Ignoring \"%@\" ...",
              service.serviceName);
        return;
    }
    
    [_discoveredServices setObject:service
                            forKey:busName];
}


// =========================================================
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


// =========================================================
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
