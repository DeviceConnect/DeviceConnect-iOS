//
//  DPAllJoynHandler.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AJNSessionOptions.h>
#import <DConnectSDK/DConnectServiceProvider.h>

@class AJNProxyBusObject;
@class DPAllJoynServiceEntity;


@interface DPAllJoynHandler : NSObject

@property (nonatomic, weak) DConnectServiceProvider *serviceProvider;
@property (nonatomic, weak) id plugin;

- (void)initAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void)destroyAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void) setServiceProvider: (DConnectServiceProvider *) serviceProvider;
- (void)discoverServices:(void(^)(BOOL result))block;
- (void)joinSessionWithBusName:(NSString *)busName
                          port:(AJNSessionPort)port
                         block:(void(^)(NSNumber *sessionId))block;
- (void)leaveSessionWithSessionId:(AJNSessionId)sessionId
                            block:(void(^)(BOOL result))block;
- (void)performOneShotSessionWithBusName:(DPAllJoynServiceEntity *)service
                                   block:(void(^)(DPAllJoynServiceEntity *service,
                                                  NSNumber *sessionId))block;
- (void)pingWithBusName:(NSString *)busName
                  block:(void(^)(BOOL result)) block;
- (AJNProxyBusObject *)proxyObjectWithService:(DPAllJoynServiceEntity *)service
                             proxyObjectClass:(Class)proxyObjectClass
                                    interface:(NSString *)interface
                                    sessionID:(AJNSessionId)sessionID;
- (NSDictionary *)discoveredAllJoynServices;

- (void)postBlock:(void(^)(void))block
        withDelay:(int64_t)delayMillis;

@end
