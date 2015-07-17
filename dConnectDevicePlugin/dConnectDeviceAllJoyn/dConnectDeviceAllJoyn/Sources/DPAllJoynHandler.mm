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


@protocol AboutClientDelegate <NSObject>

- (void)didReceiveStatusUpdateMessage:(NSString *)message;

@end


@interface DPAllJoynHandler ()
<AJNBusListener, AJNSessionListener, AJNAboutListener>
{
@private
    dispatch_queue_t handlerQueue;
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
        handlerQueue =
        dispatch_queue_create("org.deviceconnect.deviceplugin.handlerQueue",
                              NULL);
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
    
    dispatch_async(handlerQueue, ^{
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
            
            [self.bus whoImplementsInterface:@"*"];
        }
        
        block(YES);
    });
}


- (void)doDestroyAllJoynContextWithBlock:(void(^)(BOOL result))block
{
    NSLog(@"%s: destroy", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(handlerQueue, ^{
        if (_bus) {
            [_bus disconnectWithArguments:@"null"];
            [_bus stop];
            _bus = nil;
        }
        block(YES);
    });
}


- (void)doDiscover:(void(^)(BOOL result))block
{
    NSLog(@"%s: discover", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(handlerQueue, ^{
        static BOOL firstTime = YES;
        if (!firstTime) {
            for (NSArray *ifaceSet in DPAllJoynSupportedInterfaceSets) {
                for (NSString *iface in ifaceSet) {
                    [_bus cancelWhoImplements:iface];
                }
            }
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
    });
}


- (void)doJoinSessionWithBusName:(NSString *)busName
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
    
    dispatch_async(handlerQueue, ^{
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


- (void)doLeaveSessionWithSessionId:(AJNSessionId)sessionId
                              block:(void(^)(BOOL result))block
{
    NSLog(@"%s: leaveSession", __PRETTY_FUNCTION__);
    if (!block) {
        NSLog(@"%s: block can not be nil.", __PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(handlerQueue, ^{
        QStatus status = [self.bus leaveSession:sessionId];
        block(ER_OK == status);
    });
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
    
    [self doJoinSessionWithBusName:busName
                              port:port
                             block:
     ^(NSNumber *sessionIdObj) {
         if (!sessionIdObj) {
             NSLog(@"#### Failed to join a session.");
             return;
         }
         AJNSessionId sessionId = sessionIdObj.unsignedIntValue;
         
         // Create AboutProxy
         AJNAboutProxy *aboutProxy =
         [[AJNAboutProxy alloc] initWithBusAttachment:self.bus
                                              busName:busName
                                            sessionId:sessionId];
         
         // Make a call to GetAboutData and GetVersion
         uint16_t aboutVersion;
         NSMutableDictionary *aboutData;
         [aboutProxy getVersion:&aboutVersion];
         [aboutProxy getAboutDataForLanguage:@"en"
                             usingDictionary:&aboutData];
         NSLog(@"#### Version: %d", version);
         NSLog(@"#### AboutData:\n%@", aboutData.description);
         
         [self doLeaveSessionWithSessionId:sessionId
                                     block:
          ^(BOOL result) {
              
          }];
     }];
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
