//
//  DPAllJoynSystemProfile.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>


@interface DPAllJoynSystemProfile : DConnectSystemProfile

@property (readonly) NSString *const version;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithVersion:(NSString *)version NS_DESIGNATED_INITIALIZER;
+ (instancetype) systemProfileWithVersion:(NSString *)version;

@end
