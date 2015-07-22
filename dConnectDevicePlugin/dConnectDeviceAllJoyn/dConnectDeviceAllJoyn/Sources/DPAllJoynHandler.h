//
//  DPAllJoynHandler.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AJNSessionOptions.h>


@interface DPAllJoynHandler : NSObject

- (void)initAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void)destroyAllJoynContextWithBlock:(void(^)(BOOL result))block;
- (void)discoverServices:(void(^)(BOOL result))block;
- (void)joinSessionWithBusName:(NSString *)busName
                          port:(AJNSessionPort)port
                         block:(void(^)(NSNumber *sessionId))block;
- (void)leaveSessionWithSessionId:(AJNSessionId)sessionId
                            block:(void(^)(BOOL result))block;
- (NSDictionary *)discoveredAllJoynServices;

- (void)postBlock:(void(^)())block
        withDelay:(int64_t)delayMillis;

@end
