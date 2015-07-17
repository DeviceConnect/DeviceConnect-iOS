//
//  DPAllJoynHandler.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AJNSessionOptions.h>


extern NSArray *const DPAllJoynSingleLampInterfaceSet;
extern NSArray *const DPAllJoynLampControllerInterfaceSet;
extern NSArray *const DPAllJoynSupportedInterfaceSets;


@interface DPAllJoynHandler : NSObject

//- (void)run;
- (void)initAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void)doDestroyAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void)doDiscover:(void(^)(BOOL result))block;
- (void)doJoinSessionWithBusName:(NSString *)busName
                            port:(AJNSessionPort)port
                           block:(void(^)(NSNumber *sessionId))block;
- (void)doLeaveSessionWithSessionId:(AJNSessionId)sessionId
                              block:(void(^)(BOOL result))block;

@end
